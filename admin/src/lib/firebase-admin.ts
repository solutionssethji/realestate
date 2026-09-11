import * as admin from "firebase-admin";

if (!admin.apps.length) {
  try {
    if (process.env.FIREBASE_PRIVATE_KEY) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          // Handle escaped newlines in the private key
          privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
        }),
      });
      console.log("Firebase Admin initialized with credentials.");
    } else {
      admin.initializeApp();
      console.log(
        "Firebase Admin initialized without credentials (ADC fallback).",
      );
    }
  } catch (error) {
    console.error("Firebase Admin initialization error", error);
    // Allow the process to continue during build, but if an app didn't initialize, we must at least initialize an empty one to prevent crashes on export
    if (!admin.apps.length) {
      admin.initializeApp();
    }
  }
}

export const adminDb = admin.firestore();
export const adminAuth = admin.auth();
export const adminMessaging = admin.messaging();
