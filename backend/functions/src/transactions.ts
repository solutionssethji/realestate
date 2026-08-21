import * as functions from "firebase-functions/v2";
import * as admin from "firebase-admin";

export const createTransaction = functions.https.onCall(async (request) => {
  // Enforce authentication
  if (!request.auth || !request.auth.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be authenticated to create a transaction.",
    );
  }

  const { customerName, customerEmail, customerMobile, amount, type, status } =
    request.data;
  const db = admin.firestore();

  try {
    // Find the highest existing transactionId
    const snap = await db
      .collection("transactions")
      .orderBy("transactionId", "desc")
      .limit(1)
      .get();

    let nextNum = 10001;
    if (!snap.empty) {
      const lastTxn = snap.docs[0].data();
      if (lastTxn.transactionId && lastTxn.transactionId.startsWith("TXN-")) {
        const lastNum = parseInt(lastTxn.transactionId.replace("TXN-", ""));
        if (!isNaN(lastNum)) {
          nextNum = lastNum + 1;
        }
      }
    }

    const transactionId = `TXN-${nextNum}`;
    const newRef = db.collection("transactions").doc();

    const payload = {
      id: newRef.id,
      transactionId,
      customerName: customerName || "Unknown Customer",
      customerEmail: customerEmail || "",
      customerMobile: customerMobile || "",
      amount: amount || 0,
      type: type || "Other",
      status: status || "PENDING",
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      createdBy: request.auth?.uid || "admin-script",
    };

    await newRef.set(payload);

    return { success: true, transactionId, id: newRef.id };
  } catch (error) {
    console.error("Error creating transaction:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Unable to create transaction.",
    );
  }
});
