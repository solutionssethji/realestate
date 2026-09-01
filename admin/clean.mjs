import { initializeApp } from "firebase/app";
import { getFirestore, deleteDoc, doc, collection, getDocs } from "firebase/firestore";

const firebaseConfig = {
  apiKey: "AIzaSyBo6iwYf1NvlTrGH4OpzC8zpiVEmSuSrF8",
  authDomain: "shubhaytanam-buildtech-pvt-ltd.firebaseapp.com",
  projectId: "shubhaytanam-buildtech-pvt-ltd",
  storageBucket: "shubhaytanam-buildtech-pvt-ltd.firebasestorage.app",
  messagingSenderId: "806384462409",
  appId: "1:806384462409:web:de2e73aa69df8d39362d98",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function clean() {
  console.log("Deleting legalPolicies...");
  try {
    await deleteDoc(doc(db, "setting", "legalPolicies"));
    console.log("Deleted setting/legalPolicies");
  } catch (e) {
    console.error("Error deleting legalPolicies:", e.message);
  }

  console.log("Fetching faqs...");
  try {
    const snap = await getDocs(collection(db, "faqs"));
    console.log(`Found ${snap.size} faqs. Deleting...`);
    for (const d of snap.docs) {
      await deleteDoc(doc(db, "faqs", d.id));
    }
    console.log("Deleted all faqs.");
  } catch (e) {
    console.error("Error deleting faqs:", e.message);
  }
  
  process.exit(0);
}

clean();
