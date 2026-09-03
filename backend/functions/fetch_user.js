const { initializeApp } = require('firebase/app');
const { getFirestore, doc, getDoc } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: 'AIzaSyBo6iwYf1NvlTrGH4OpzC8zpiVEmSuSrF8',
  appId: '1:806384462409:web:de2e73aa69df8d39362d98',
  projectId: 'shubhaytanam-buildtech-pvt-ltd',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function run() {
  try {
    const docRef = doc(db, 'users', 'QLzLAcUAdwPHQKqf9Ld5V5puur33');
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      console.log("User data:", docSnap.data());
    } else {
      console.log("No such document!");
    }
  } catch (error) {
    console.error("Error:", error);
  } finally {
    process.exit();
  }
}

run();
