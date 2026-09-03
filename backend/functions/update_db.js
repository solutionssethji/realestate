const { initializeApp } = require('firebase/app');
const { getFirestore, collection, getDocs } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: 'AIzaSyBo6iwYf1NvlTrGH4OpzC8zpiVEmSuSrF8',
  appId: '1:806384462409:web:de2e73aa69df8d39362d98',
  projectId: 'shubhaytanam-buildtech-pvt-ltd',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function run() {
  try {
    const usersRef = collection(db, 'users');
    const allUsers = await getDocs(usersRef);
    let referredCount = 0;
    
    console.log(`Total users in DB: ${allUsers.size}`);
    
    allUsers.forEach(doc => {
       const data = doc.data();
       if (data.referredBy) {
           console.log(`User ${doc.id} used referral: ${data.referredBy}`);
           if (data.referredBy === 'SHUBHQLZLACUA') {
               referredCount++;
           }
       }
    });

    console.log(`Total users who used SHUBHQLZLACUA: ${referredCount}`);

  } catch (error) {
    console.error("Error:", error);
  } finally {
    process.exit();
  }
}

run();
