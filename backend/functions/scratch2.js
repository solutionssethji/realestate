const admin = require('firebase-admin');
admin.initializeApp({
  projectId: "shubhaytanam-buildtech-pvt-ltd"
});
const db = admin.firestore();
async function run() {
  const p = await db.collection('projects').limit(1).get();
  console.log("Projects:", p.docs.map(d=>d.data()));
  const pl = await db.collection('plots').limit(1).get();
  console.log("Plots:", pl.docs.map(d=>d.data()));
  const o = await db.collection('offers').limit(1).get();
  console.log("Offers:", o.docs.map(d=>d.data()));
}
run().catch(console.error);
