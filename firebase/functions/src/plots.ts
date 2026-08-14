import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

export const bookPlot = functions.https.onCall(async (request) => {
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
  } catch (error: any) {
    throw new functions.https.HttpsError('failed-precondition', error.message);
  }
});
