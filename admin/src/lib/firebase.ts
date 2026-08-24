import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth, connectAuthEmulator } from "firebase/auth";
import {
  getFirestore,
  connectFirestoreEmulator,
  collection,
  query,
  where,
  getDocs,
} from "firebase/firestore";
import { getStorage, connectStorageEmulator } from "firebase/storage";
import { getFunctions, connectFunctionsEmulator } from "firebase/functions";

export const firebaseConfig = {
  apiKey: "AIzaSyBo6iwYf1NvlTrGH4OpzC8zpiVEmSuSrF8",
  authDomain: "shubhaytanam-buildtech-pvt-ltd.firebaseapp.com",
  projectId: "shubhaytanam-buildtech-pvt-ltd",
  storageBucket: "shubhaytanam-buildtech-pvt-ltd.firebasestorage.app",
  messagingSenderId: "806384462409",
  appId: "1:806384462409:web:de2e73aa69df8d39362d98",
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
    connectAuthEmulator(auth, "http://127.0.0.1:9099", {
      disableWarnings: true,
    });
    connectFirestoreEmulator(db, "127.0.0.1", 8080);
    connectStorageEmulator(storage, "127.0.0.1", 9199);
    connectFunctionsEmulator(functions, "127.0.0.1", 5001);
    (auth as any)._isEmulated = true;
  }
}

export { app, auth, db, storage, functions };

export const normalizeEmail = (value: string) => value.trim().toLowerCase();

export const findAdminOrAgentByEmail = async (email: string) => {
  const normalizedEmail = normalizeEmail(email);
  if (!normalizedEmail) {
    return null;
  }

  const adminsRef = collection(db, "admins");
  const adminQuery = query(
    adminsRef,
    where("email", "in", [normalizedEmail, email]),
  );
  const adminSnap = await getDocs(adminQuery);

  if (!adminSnap.empty) {
    return { role: "ADMIN", user: adminSnap.docs[0].data() };
  }

  const agentsRef = collection(db, "agents");
  const agentQuery = query(
    agentsRef,
    where("email", "in", [normalizedEmail, email]),
  );
  const agentSnap = await getDocs(agentQuery);

  if (!agentSnap.empty) {
    return { role: "AGENT", user: agentSnap.docs[0].data() };
  }

  return null;
};

/**
 * Creates a new Firebase Auth user without logging out the current admin user.
 * This works by spinning up a temporary secondary Firebase app instance,
 * creating the user, and immediately deleting the secondary instance.
 */
export const createAuthUser = async (
  email: string,
  password: string,
): Promise<string> => {
  const { initializeApp, deleteApp } = await import("firebase/app");
  const {
    getAuth,
    createUserWithEmailAndPassword,
    signOut,
    sendEmailVerification,
  } = await import("firebase/auth");

  const appName = `SecondaryApp_${Date.now()}`;
  const secondaryApp = initializeApp(firebaseConfig, appName);
  const secondaryAuth = getAuth(secondaryApp);

  try {
    const userCredential = await createUserWithEmailAndPassword(
      secondaryAuth,
      email,
      password,
    );
    const uid = userCredential.user.uid;

    // Immediately send verification email to the new user
    await sendEmailVerification(userCredential.user);

    await signOut(secondaryAuth);
    return uid;
  } finally {
    await deleteApp(secondaryApp);
  }
};
