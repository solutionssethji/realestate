import { initializeApp, getApps, getApp } from 'firebase/app';
import { getAuth, connectAuthEmulator } from 'firebase/auth';
import { getFirestore, connectFirestoreEmulator } from 'firebase/firestore';
import { getStorage, connectStorageEmulator } from 'firebase/storage';
import { getFunctions, connectFunctionsEmulator } from 'firebase/functions';

// Replace these with your actual Firebase project configuration
const firebaseConfig = {
  apiKey: "AIzaSyBo6iwYf1NvlTrGH4OpzC8zpiVEmSuSrF8",
  authDomain: "shubhaytanam-buildtech-pvt-ltd.firebaseapp.com",
  projectId: "shubhaytanam-buildtech-pvt-ltd",
  storageBucket: "shubhaytanam-buildtech-pvt-ltd.firebasestorage.app",
  messagingSenderId: "806384462409",
  appId: "1:806384462409:web:de2e73aa69df8d39362d98"
};

// Initialize Firebase
const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);

const auth = getAuth(app);
const db = getFirestore(app);
const storage = getStorage(app);
const functions = getFunctions(app);

const USE_FIREBASE_EMULATORS = false; // Set to true to use emulators

// Use emulators in development
if (USE_FIREBASE_EMULATORS) {
  // Check to prevent double-connecting in Hot Module Replacement (HMR)
  const isEmulated = (auth as any)._isEmulated;
  if (!isEmulated) {
    connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
    connectFirestoreEmulator(db, '127.0.0.1', 8080);
    connectStorageEmulator(storage, '127.0.0.1', 9199);
    connectFunctionsEmulator(functions, '127.0.0.1', 5001);
    (auth as any)._isEmulated = true;
  }
}

export { app, auth, db, storage, functions };
