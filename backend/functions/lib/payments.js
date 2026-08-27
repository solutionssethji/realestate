"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCustomerPayments = exports.sendPaymentConfirmations = exports.verifyPayment = exports.initiatePayment = void 0;
const functions = __importStar(require("firebase-functions/v2"));
const admin = __importStar(require("firebase-admin"));
const razorpay_1 = __importDefault(require("razorpay"));
const crypto = __importStar(require("crypto"));
const twilio_1 = require("twilio");
const razorpay = new razorpay_1.default({
    key_id: process.env.RAZORPAY_KEY_ID || 'mock_key_id',
    key_secret: process.env.RAZORPAY_KEY_SECRET || 'mock_key_secret',
});
async function createPaymentWithVoucher(paymentRef, data) {
    const counterRef = admin.firestore().collection('counters').doc('payments');
    await admin.firestore().runTransaction(async (transaction) => {
        const counterSnapshot = await transaction.get(counterRef);
        const lastVoucherNumber = Number(counterSnapshot.data()?.lastVoucherNumber ?? 0);
        const voucherNumber = lastVoucherNumber + 1;
        transaction.set(counterRef, { lastVoucherNumber: voucherNumber }, { merge: true });
        transaction.set(paymentRef, { ...data, voucherNumber });
    });
}
// 1. Payment Initialization (Real Gateway)
exports.initiatePayment = functions.https.onCall(async (request) => {
    const { amount, projectId, plotId, description, referenceId } = request.data;
    const uid = request.auth?.uid;
    if (!amount) {
        throw new functions.https.HttpsError('invalid-argument', 'Missing amount.');
    }
    // Create a pending payment record in Firestore securely
    const paymentRef = admin.firestore().collection('payments').doc();
    try {
        const orderOptions = {
            amount: Math.round(amount * 100), // amount in smallest currency unit (paise)
            currency: 'INR',
            receipt: paymentRef.id,
        };
        // Fallback to mock order ID if credentials are mock/missing
        let orderId = `mock_order_${Date.now()}`;
        if (process.env.RAZORPAY_KEY_ID && !process.env.RAZORPAY_KEY_ID.startsWith('mock')) {
            const order = await razorpay.orders.create(orderOptions);
            orderId = order.id;
        }
        await createPaymentWithVoucher(paymentRef, {
            id: paymentRef.id,
            userId: uid || 'anonymous',
            projectId: projectId || null,
            plotId: plotId || null,
            referenceId: referenceId || null,
            amount,
            currency: 'INR',
            status: 'PENDING',
            description: description || 'Plot Booking',
            orderId: orderId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        return { success: true, paymentId: paymentRef.id, orderId: orderId };
    }
    catch (error) {
        console.error('Error initiating payment:', error);
        throw new functions.https.HttpsError('internal', 'Unable to initiate payment.');
    }
});
// 2. Secure Server-Side Verification
exports.verifyPayment = functions.https.onCall(async (request) => {
    const { paymentId, razorpay_order_id, razorpay_payment_id, razorpay_signature, status } = request.data;
    if (!paymentId) {
        throw new functions.https.HttpsError('invalid-argument', 'Payment ID required.');
    }
    const paymentRef = admin.firestore().collection('payments').doc(paymentId);
    const paymentDoc = await paymentRef.get();
    if (!paymentDoc.exists) {
        throw new functions.https.HttpsError('not-found', 'Payment not found.');
    }
    let finalStatus = 'FAILED';
    // If client says success, verify the signature cryptographically
    if (status === 'success' || status === 'SUCCESS') {
        if (process.env.RAZORPAY_KEY_SECRET && !process.env.RAZORPAY_KEY_SECRET.startsWith('mock')) {
            const body = razorpay_order_id + "|" + razorpay_payment_id;
            const expectedSignature = crypto
                .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
                .update(body.toString())
                .digest('hex');
            if (expectedSignature === razorpay_signature) {
                finalStatus = 'SUCCESS';
            }
            else {
                console.error('Invalid signature for payment:', paymentId);
                finalStatus = 'FAILED';
            }
        }
        else {
            // In sandbox/mock mode without real keys, trust the success payload
            finalStatus = 'SUCCESS';
        }
    }
    else if (status === 'cancelled' || status === 'CANCELLED') {
        finalStatus = 'CANCELLED';
    }
    await paymentRef.update({
        status: finalStatus,
        gatewayPaymentId: razorpay_payment_id || null,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return { success: finalStatus === 'SUCCESS', status: finalStatus };
});
// 3. SMS & WhatsApp Confirmation Trigger
exports.sendPaymentConfirmations = functions.firestore.onDocumentUpdated('payments/{paymentId}', async (event) => {
    const dataBefore = event.data?.before.data();
    const dataAfter = event.data?.after.data();
    // Only trigger when status changes to SUCCESS
    if (dataBefore?.status !== 'SUCCESS' && dataAfter?.status === 'SUCCESS') {
        const paymentId = event.params.paymentId;
        const amount = dataAfter.amount;
        const phone = dataAfter.customerPhone || '+910000000000'; // Replace with actual logic to fetch user phone
        if (!process.env.TWILIO_ACCOUNT_SID || process.env.TWILIO_ACCOUNT_SID.startsWith('mock')) {
            console.log('Mock Twilio: SMS & WhatsApp would be sent to', phone, 'for payment', paymentId);
            return null;
        }
        try {
            const twilioClient = new twilio_1.Twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
            const messageBody = `Success! We have received your payment of INR ${amount}. Transaction ID: ${paymentId}. Thank you for choosing us!`;
            // Send SMS
            await twilioClient.messages.create({
                body: messageBody,
                from: process.env.TWILIO_PHONE_NUMBER,
                to: phone
            });
            // Send WhatsApp
            await twilioClient.messages.create({
                body: messageBody,
                from: `whatsapp:${process.env.TWILIO_WHATSAPP_NUMBER}`,
                to: `whatsapp:${phone}`
            });
            console.log('Confirmations sent successfully for', paymentId);
        }
        catch (error) {
            console.error('Failed to send Twilio notifications:', error);
        }
    }
    return null;
});
// 4. Secure Payment History Endpoint (OTP verified phone auth)
exports.getCustomerPayments = functions.https.onCall(async (request) => {
    // Enforce that the user is authenticated (e.g. via Phone Auth)
    if (!request.auth || !request.auth.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated.');
    }
    const uid = request.auth.uid;
    const phone = request.auth.token.phone_number;
    try {
        // We can fetch payments by uid, or by phone if they were recorded under phone.
        // Assuming we store `userId` which maps to the Auth UID.
        const snapshot = await admin.firestore().collection('payments')
            .where('userId', '==', uid)
            .orderBy('createdAt', 'desc')
            .get();
        const payments = snapshot.docs.map(doc => {
            const data = doc.data();
            return {
                id: doc.id,
                voucherNumber: data.voucherNumber,
                amount: data.amount,
                currency: data.currency,
                status: data.status,
                description: data.description,
                mode: data.mode,
                paymentType: data.paymentType,
                transactionId: data.transactionId || data.referenceId,
                bankName: data.bankName,
                notes: data.notes,
                bookingId: data.bookingId,
                projectId: data.projectId,
                plotId: data.plotId,
                orderId: data.orderId,
                createdAt: data.createdAt?.toDate().toISOString(),
            };
        });
        return { success: true, payments, phone };
    }
    catch (error) {
        console.error('Error fetching payments:', error);
        throw new functions.https.HttpsError('internal', 'Unable to fetch payment history.');
    }
});
//# sourceMappingURL=payments.js.map