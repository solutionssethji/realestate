import * as admin from 'firebase-admin';
import { setGlobalOptions } from 'firebase-functions/v2';

setGlobalOptions({
  maxInstances: 1,
  memory: '256MiB',
  concurrency: 80,
  timeoutSeconds: 60
});


// Initialize the Firebase Admin SDK
admin.initializeApp();

// Export Cloud Functions
export * from './admin';
export * from './payments';
export * from './plots';
export * from './notifications';
export * from './transactions';
// offers module removed - expiry now handled client-side via endDate filter
