import { onDocumentCreated, onDocumentWritten } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
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

export const sendBroadcastNotification = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Login required to send notifications.");
  }

  const db = admin.firestore();
  const adminSnap = await db.collection("admins").doc(request.auth.uid).get();
  if (!adminSnap.exists) {
    throw new HttpsError("permission-denied", "Only admins can send notifications.");
  }

  const title = String(request.data?.title ?? "").trim();
  const body = String(request.data?.body ?? "").trim();

  if (!title || !body) {
    throw new HttpsError("invalid-argument", "Title and body are required.");
  }

  const usersSnap = await db.collection("users").get();
  const allTokens: string[] = [];
  const userIds: string[] = [];

  for (const userDoc of usersSnap.docs) {
    const userData = userDoc.data() ?? {};
    const fcmTokens = Array.isArray(userData.fcmTokens)
      ? userData.fcmTokens.filter((token: unknown) => typeof token === "string" && token.trim())
      : [];
    const legacyToken = typeof userData.fcmToken === "string" && userData.fcmToken.trim()
      ? [userData.fcmToken.trim()]
      : [];

    const uniqueTokens = [...new Set([...fcmTokens, ...legacyToken])];
    if (uniqueTokens.length === 0) continue;

    userIds.push(userDoc.id);
    allTokens.push(...uniqueTokens);

    const notificationId = `${Date.now()}-${userDoc.id}`;
    await userDoc.ref.collection("notifications").doc(notificationId).set({
      id: notificationId,
      type: "ADMIN_BROADCAST",
      title,
      body,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      payload: {
        senderId: request.auth.uid,
        target: "ALL_USERS",
      },
    });
  }

  if (allTokens.length === 0) {
    const adminNotificationRef = db.collection("adminNotifications").doc();
    await adminNotificationRef.set({
      id: adminNotificationRef.id,
      type: "ADMIN_BROADCAST",
      title,
      body,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      target: "ALL_USERS",
      recipients: 0,
    });

    return { success: true, sent: 0, failed: 0, total: 0 };
  }

  const adminNotificationRef = db.collection("adminNotifications").doc();
  await adminNotificationRef.set({
    id: adminNotificationRef.id,
    type: "ADMIN_BROADCAST",
    title,
    body,
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    target: "ALL_USERS",
    recipients: userIds.length,
  });

  const result = await admin.messaging().sendEachForMulticast({
    tokens: [...new Set(allTokens)],
    notification: {
      title,
      body,
    },
    data: {
      type: "ADMIN_BROADCAST",
      title,
      body,
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

  return {
    success: true,
    sent: result.successCount,
    failed: result.failureCount,
    total: result.successCount + result.failureCount,
  };
});

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
