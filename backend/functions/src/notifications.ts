import { onDocumentCreated, onDocumentWritten } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

async function resolveCustomerFcmTokens(customerId: string) {
  if (!customerId) return [];

  const userDoc = await admin.firestore().collection("users").doc(customerId).get();
  if (!userDoc.exists) return [];

  const userData = userDoc.data() ?? {};
  const storedTokens = Array.isArray(userData.fcmTokens)
    ? userData.fcmTokens.filter((token: unknown) => typeof token === "string" && token.trim())
    : [];
  const legacyToken = typeof userData.fcmToken === "string" && userData.fcmToken.trim()
    ? [userData.fcmToken.trim()]
    : [];

  return [...new Set([...storedTokens, ...legacyToken])];
}

async function removeInvalidFcmTokens(customerId: string, invalidTokens: string[]) {
  if (!customerId || invalidTokens.length === 0) return;

  const userRef = admin.firestore().collection("users").doc(customerId);
  await userRef.update({
    fcmTokens: admin.firestore.FieldValue.arrayRemove(...invalidTokens),
  });
}

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
      titleKey: "notif_site_visit_title",
      messageKey: "notif_site_visit_message",
      messageParams: { name: customerName },
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
      titleKey: "notif_enquiry_title",
      messageKey: "notif_enquiry_message",
      messageParams: { name: customerName },
      title: "New Enquiry",
      message: `New enquiry received from ${customerName}`,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  },
);

export const onPlotAssigned = onDocumentWritten(
  "assignPlots/{assignmentId}",
  async (event) => {
    const snapshot = event.data?.after;
    if (!snapshot || !snapshot.exists) {
      return;
    }

    const assignment = snapshot.data() ?? {};
    const customerId = assignment.customerId || assignment.userId;
    if (!customerId) {
      return;
    }

    const db = admin.firestore();
    const plotNumber = assignment.plotNumber || assignment.plotId || "your plot";
    const projectName = assignment.projectName || "Project";
    const title = "Plot assigned";
    const body = `${projectName} — Plot ${plotNumber} has been assigned to you.`;

    const notificationId = `${snapshot.id}-${Date.now()}`;
    const userNotificationRef = db
      .collection("users")
      .doc(customerId)
      .collection("notifications")
      .doc(notificationId);

    await userNotificationRef.set({
      id: userNotificationRef.id,
      type: "PLOT_ASSIGNED",
      relatedId: assignment.plotId || snapshot.id,
      title,
      body,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      payload: {
        plotId: assignment.plotId || null,
        projectId: assignment.projectId || null,
        assignmentId: snapshot.id,
      },
    });

    const tokens = await resolveCustomerFcmTokens(customerId);
    if (tokens.length === 0) {
      return;
    }

    const result = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title,
        body,
      },
      data: {
        type: "PLOT_ASSIGNED",
        plotId: assignment.plotId || "",
        projectId: assignment.projectId || "",
        assignmentId: snapshot.id,
      },
      android: {
        priority: "high",
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
          },
        },
      },
    });

    if (result.failureCount > 0) {
      const invalidTokens = result.responses
        .map((response, index) => ({ response, index }))
        .filter(({ response }) => !response.success)
        .map(({ index }) => tokens[index])
        .filter((token): token is string => Boolean(token));

      if (invalidTokens.length > 0) {
        await removeInvalidFcmTokens(customerId, invalidTokens);
      }
    }
  },
);
