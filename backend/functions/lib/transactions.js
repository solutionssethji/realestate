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
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTransaction = void 0;
const functions = __importStar(require("firebase-functions/v2"));
const admin = __importStar(require("firebase-admin"));
exports.createTransaction = functions.https.onCall(async (request) => {
    // Enforce authentication
    if (!request.auth || !request.auth.uid) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated to create a transaction.');
    }
    const { customerName, customerEmail, customerMobile, amount, type, status } = request.data;
    const db = admin.firestore();
    try {
        // Find the highest existing transactionId
        const snap = await db.collection('transactions')
            .orderBy('transactionId', 'desc')
            .limit(1)
            .get();
        let nextNum = 10001;
        if (!snap.empty) {
            const lastTxn = snap.docs[0].data();
            if (lastTxn.transactionId && lastTxn.transactionId.startsWith('TXN-')) {
                const lastNum = parseInt(lastTxn.transactionId.replace('TXN-', ''));
                if (!isNaN(lastNum)) {
                    nextNum = lastNum + 1;
                }
            }
        }
        const transactionId = `TXN-${nextNum}`;
        const newRef = db.collection('transactions').doc();
        const payload = {
            id: newRef.id,
            transactionId,
            customerName: customerName || 'Unknown Customer',
            customerEmail: customerEmail || '',
            customerMobile: customerMobile || '',
            amount: amount || 0,
            type: type || 'Other',
            status: status || 'PENDING',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdBy: request.auth?.uid || 'admin-script'
        };
        await newRef.set(payload);
        return { success: true, transactionId, id: newRef.id };
    }
    catch (error) {
        console.error('Error creating transaction:', error);
        throw new functions.https.HttpsError('internal', 'Unable to create transaction.');
    }
});
//# sourceMappingURL=transactions.js.map