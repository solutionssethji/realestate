const admin = require('firebase-admin');
admin.initializeApp({
  projectId: "shubhaytanam-buildtech-pvt-ltd"
});
const db = admin.firestore();
async function run() {
  await db.collection('transactions').add({test: true});
  console.log("Success");
}
run().catch(console.error);
