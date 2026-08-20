import * as functions from 'firebase-functions/v2';
import * as admin from 'firebase-admin';

// Initialize admin bootstrap securely.
// In a real app, this might be triggered by a specific secret or only run once.
export const bootstrapAdmin = functions.https.onCall(async (request) => {
  const { email, password, name, secret } = request.data;
  
  // Very simple protection for the bootstrap function
  if (secret !== 'SUPER_SECRET_BOOTSTRAP_KEY') {
    throw new functions.https.HttpsError('permission-denied', 'Invalid bootstrap secret.');
  }

  try {
    // Create the user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
    });

    // Set custom claims for admin
    await admin.auth().setCustomUserClaims(userRecord.uid, { admin: true });

    // Create the Firestore document in 'admins' collection
    await admin.firestore().collection('admins').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email,
      name,
      role: 'ADMIN',
      status: 'ACTIVE',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, uid: userRecord.uid };
  } catch (error: any) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
