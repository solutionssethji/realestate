import * as admin from 'firebase-admin';

try {
  admin.initializeApp();
  console.log('Success empty');
  const db = admin.firestore();
  console.log('Firestore initialized');
} catch (e) {
  console.error('Error empty:', e);
}
