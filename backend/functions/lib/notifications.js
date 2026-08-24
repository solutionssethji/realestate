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
exports.onEnquiryCreated = exports.onSiteVisitCreated = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = __importStar(require("firebase-admin"));
exports.onSiteVisitCreated = (0, firestore_1.onDocumentCreated)("siteVisits/{docId}", async (event) => {
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
});
exports.onEnquiryCreated = (0, firestore_1.onDocumentCreated)("enquiries/{docId}", async (event) => {
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
        }
        catch (_) {
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
});
//# sourceMappingURL=notifications.js.map