"use strict";
// NOTE: expireOldOffers scheduled function has been intentionally removed.
// Offer expiry is now handled client-side by filtering on endDate in the mobile app
// and in the admin panel query. This eliminates Cloud Scheduler & Pub/Sub billing.
// Admin can also manually set status to EXPIRED from the admin panel.
//# sourceMappingURL=offers.js.map