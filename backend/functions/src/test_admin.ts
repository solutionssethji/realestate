import * as admin from "firebase-admin";

// Initialize Firebase Admin (make sure we use the default app or supply a service account if needed)
try {
  admin.initializeApp();
} catch (e) {}

async function run() {
  const db = admin.firestore();
  const snapshot = await db.collection("plots").limit(3).get();
  snapshot.forEach(doc => {
    const data = doc.data();
    console.log(`ID: ${doc.id}`);
    console.log(`Plot Number: ${typeof data.plotNumber} ${data.plotNumber}`);
    console.log('---');
  });
}

run().catch(console.error);
