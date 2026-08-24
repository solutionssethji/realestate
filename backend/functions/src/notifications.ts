import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

export const onSiteVisitCreated = onDocumentCreated(
  "siteVisits/{docId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const data = snapshot.data();
    const customerName = data.customerName || "a customer";
    const siteVisitId = snapshot.id;

    const db = admin.firestore();
    const notificationRef = db
      .collection("adminNotifications")
      .doc(siteVisitId);

    await notificationRef.set({
      id: notificationRef.id,
      type: "SITE_VISIT",
      relatedId: siteVisitId,
      // Add keys for localization
      titleKey: "notif_site_visit_title",
      messageKey: "notif_site_visit_message",
      messageParams: { name: customerName },

      // Provide fallbacks for backwards compatibility in case UI hasn't updated
      title: "New Site Visit Booking",
      message: `New site visit booking received from ${customerName}`,

      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  },
);

export const onEnquiryCreated = onDocumentCreated(
  "enquiries/{docId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const data = snapshot.data();
    const enquiryId = snapshot.id;
    const db = admin.firestore();

    // Resolve customer name from users collection via customerId
    let customerName = "a customer";
    const customerId = data.customerId;
    if (customerId) {
      try {
        const userDoc = await db.collection("users").doc(customerId).get();
        if (userDoc.exists) {
          const userData = userDoc.data();
          customerName = userData?.fullName || userData?.name || "a customer";
        }
      } catch (_) {
        // fallback to default
      }
    }

    const notificationRef = db.collection("adminNotifications").doc(enquiryId);

    await notificationRef.set({
      id: notificationRef.id,
      type: "ENQUIRY",
      relatedId: enquiryId,
      // Add keys for localization
      titleKey: "notif_enquiry_title",
      messageKey: "notif_enquiry_message",
      messageParams: { name: customerName },

      // Provide fallbacks for backwards compatibility in case UI hasn't updated
      title: "New Enquiry",
      message: `New enquiry received from ${customerName}`,

      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  },
);
