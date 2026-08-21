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
exports.expireOldOffers = void 0;
const scheduler_1 = require("firebase-functions/v2/scheduler");
const admin = __importStar(require("firebase-admin"));
/**
 * Scheduled function that runs every 12 hours.
 * It finds all offers that are currently 'active' but have an 'endDate'
 * in the past, and updates their status to inactive.
 * This prevents the admin from having to manually uncheck the active status.
 */
exports.expireOldOffers = (0, scheduler_1.onSchedule)('every 12 hours', async (event) => {
    const db = admin.firestore();
    const nowIso = new Date().toISOString();
    // Find offers that are active but their endDate has passed
    const expiredOffersQuery = await db
        .collection('offers')
        .where('status', '==', 'ACTIVE')
        .where('endDate', '<', nowIso)
        .get();
    if (expiredOffersQuery.empty) {
        console.log('No expired offers found to deactivate.');
        return;
    }
    const batch = db.batch();
    let count = 0;
    expiredOffersQuery.forEach((doc) => {
        batch.update(doc.ref, { status: 'EXPIRED' });
        count++;
    });
    await batch.commit();
    console.log(`Successfully deactivated ${count} expired offers.`);
});
//# sourceMappingURL=offers.js.map