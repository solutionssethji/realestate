"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onOfferCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = __importStar(require("firebase-admin"));
exports.onOfferCreated = (0, firestore_1.onDocumentCreated)("offers/{offerId}", async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
        return;
    }
    const offerData = snapshot.data();
    const offerTitleEn = offerData.title?.en || "New Offer!";
    const offerBodyEn = offerData.description?.en || "Check out our latest offer.";
    const db = admin.firestore();
    const usersSnap = await db.collection("users").get();
    const allTokens = [];
    const userIds = [];
    // Gather all tokens and create in-app notifications
    for (const userDoc of usersSnap.docs) {
        const userData = userDoc.data() ?? {};
        const fcmTokens = Array.isArray(userData.fcmTokens)
            ? userData.fcmTokens.filter((token) => typeof token === "string" && token.trim())
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
});
//# sourceMappingURL=offers.js.map