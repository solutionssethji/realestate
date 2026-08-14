import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';
import Razorpay from 'razorpay';
import * as crypto from 'crypto';
import { Twilio } from 'twilio';

const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID || 'mock_key_id',
  key_secret: process.env.RAZORPAY_KEY_SECRET || 'mock_key_secret',
});

// 1. Payment Initialization (Real Gateway)
export const initiatePayment = functions.https.onCall(async (request) => {
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

    await paymentRef.set({
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
  } catch (error) {
    console.error('Error initiating payment:', error);
    throw new functions.https.HttpsError('internal', 'Unable to initiate payment.');
  }
});

// 2. Secure Server-Side Verification
export const verifyPayment = functions.https.onCall(async (request) => {
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
      } else {
        console.error('Invalid signature for payment:', paymentId);
        finalStatus = 'FAILED';
      }
    } else {
      // In sandbox/mock mode without real keys, trust the success payload
      finalStatus = 'SUCCESS';
    }
  } else if (status === 'cancelled' || status === 'CANCELLED') {
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
export const sendPaymentConfirmations = functions.firestore.onDocumentUpdated('payments/{paymentId}', async (event) => {
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
      const twilioClient = new Twilio(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
      
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
    } catch (error) {
      console.error('Failed to send Twilio notifications:', error);
    }
  }
  return null;
});

// 4. Secure Payment History Endpoint (OTP verified phone auth)
export const getCustomerPayments = functions.https.onCall(async (request) => {
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
        amount: data.amount,
        currency: data.currency,
        status: data.status,
        description: data.description,
        orderId: data.orderId,
        createdAt: data.createdAt?.toDate().toISOString(),
      };
    });

    return { success: true, payments, phone };
  } catch (error) {
    console.error('Error fetching payments:', error);
    throw new functions.https.HttpsError('internal', 'Unable to fetch payment history.');
  }
});
