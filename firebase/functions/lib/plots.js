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
exports.bookPlot = void 0;
const functions = __importStar(require("firebase-functions/v2"));
const admin = __importStar(require("firebase-admin"));
exports.bookPlot = functions.https.onCall(async (request) => {
    const { plotId } = request.data;
    if (!request.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'Must be logged in to book.');
    }
    const plotRef = admin.firestore().collection('plots').doc(plotId);
    try {
        // Use a Firestore transaction to prevent race conditions
        await admin.firestore().runTransaction(async (transaction) => {
            const plotDoc = await transaction.get(plotRef);
            if (!plotDoc.exists) {
                throw new Error('Plot does not exist.');
            }
            const plotData = plotDoc.data();
            if (plotData?.status !== 'AVAILABLE') {
                throw new Error('Plot is not available for booking.');
            }
            // Mark as HOLD or BOOKED_SOLD
            transaction.update(plotRef, {
                status: 'HOLD',
                bookedBy: request.auth?.uid,
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
        });
        return { success: true, message: 'Plot successfully reserved.' };
    }
    catch (error) {
        throw new functions.https.HttpsError('failed-precondition', error.message);
    }
});
//# sourceMappingURL=plots.js.map