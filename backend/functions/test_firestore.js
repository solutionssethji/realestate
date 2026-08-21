const { initializeApp } = require('firebase/app');
const { getFirestore, collection, getDocs } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: "dummy",
  authDomain: "dummy",
  projectId: "real-estate-platform-65c3b",
};
// Actually we can just read the firebase admin credentials if this is the backend.
