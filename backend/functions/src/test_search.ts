import * as admin from "firebase-admin";
admin.initializeApp();
const db = admin.firestore();

async function run() {
  const searchQuery = "1";
  
  let baseQuery: any = db.collection("plots");
  baseQuery = baseQuery.where("plotNumber", ">=", searchQuery);
  baseQuery = baseQuery.where("plotNumber", "<=", searchQuery + "\uf8ff");
  baseQuery = baseQuery.orderBy("plotNumber", "asc");

  try {
    const snap = await baseQuery.get();
    console.log(`Found ${snap.docs.length} plots`);
    snap.docs.forEach((d: any) => console.log(d.data().plotNumber));
  } catch(e) {
    console.error("Error:", e);
  }
}
run().catch(console.error);
