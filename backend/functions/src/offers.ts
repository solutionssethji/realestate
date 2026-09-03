import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

export const onOfferCreated = onDocumentCreated(
  "offers/{offerId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      return;
    }

    const offerData = snapshot.data();
    const offerTitleEn = offerData.title?.en || "New Offer!";
    const offerBodyEn = offerData.description?.en || "Check out our latest offer.";

    const db = admin.firestore();
    const usersSnap = await db.collection("users").get();
    
    const allTokens: string[] = [];
    const userIds: string[] = [];

    // Gather all tokens and create in-app notifications
    for (const userDoc of usersSnap.docs) {
      const userData = userDoc.data() ?? {};
      const fcmTokens = Array.isArray(userData.fcmTokens)
        ? userData.fcmTokens.filter((token: unknown) => typeof token === "string" && token.trim())
        : [];
      const legacyToken = typeof userData.fcmToken === "string" && userData.fcmToken.trim()
        ? [userData.fcmToken.trim()]
        : [];

      const uniqueTokens = [...new Set([...fcmTokens, ...legacyToken])];
      if (uniqueTokens.length > 0) {
        allTokens.push(...uniqueTokens);
      }
      
      userIds.push(userDoc.id);

      const notificationId = `${Date.now()}-${userDoc.id}-offer`;
      await userDoc.ref.collection("notifications").doc(notificationId).set({
        id: notificationId,
        type: "NEW_OFFER",
        title: offerTitleEn,
        body: offerBodyEn,
        read: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        resourceId: snapshot.id,
        payload: {
          offerId: snapshot.id,
        },
      });
    }

    if (allTokens.length === 0) {
      console.log("No users with FCM tokens found.");
      return;
    }

    // Send multicast message
    const result = await admin.messaging().sendEachForMulticast({
      tokens: [...new Set(allTokens)],
      notification: {
        title: offerTitleEn,
        body: offerBodyEn,
      },
      data: {
        type: "NEW_OFFER",
        offerId: snapshot.id,
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

    console.log(`Successfully sent ${result.successCount} messages. Failed: ${result.failureCount}`);
  }
);
