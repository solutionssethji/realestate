import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

/**
 * Scheduled function that runs every 12 hours.
 * It finds all offers that are currently 'active' but have an 'endDate'
 * in the past, and updates their status to inactive.
 * This prevents the admin from having to manually uncheck the active status.
 */
export const expireOldOffers = onSchedule("every 12 hours", async (event) => {
  const db = admin.firestore();
  const nowIso = new Date().toISOString();

  // Find offers that are active but their endDate has passed
  const expiredOffersQuery = await db
    .collection("offers")
    .where("status", "==", "ACTIVE")
    .where("endDate", "<", nowIso)
    .get();

  if (expiredOffersQuery.empty) {
    console.log("No expired offers found to deactivate.");
    return;
  }

  const batch = db.batch();
  let count = 0;

  expiredOffersQuery.forEach((doc) => {
    batch.update(doc.ref, { status: "EXPIRED" });
    count++;
  });

  await batch.commit();
  console.log(`Successfully deactivated ${count} expired offers.`);
});
