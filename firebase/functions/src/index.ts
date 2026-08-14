import * as admin from 'firebase-admin';

// Initialize the Firebase Admin SDK
admin.initializeApp();

// Export Cloud Functions
export * from './admin';
export * from './payments';
export * from './plots';
export * from './notifications';
