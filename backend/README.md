# Shubhaytanam Connect - Backend Cloud Functions ☁️

This directory contains the Firebase backend for the Shubhaytanam Connect platform, including Cloud Functions (Node.js/TypeScript), Firestore Security Rules, and Storage Rules.

## 🚀 Local Development

### Prerequisites
- Node.js & npm
- Firebase CLI (`npm install -g firebase-tools`)

### Setup

```bash
# Navigate to the functions directory
cd backend/functions

# Install dependencies
npm install

# Build the TypeScript code
npm run build
```

### Emulators
You can run the Firebase Emulator Suite to test functions and database rules locally without affecting production data.

```bash
# Start the emulators
firebase emulators:start
```

## 📦 Deployment

Deploy the Cloud Functions, Firestore Rules, and indexes to your Firebase project:

```bash
# Deploy only functions
firebase deploy --only functions

# Deploy only Firestore rules
firebase deploy --only firestore:rules

# Deploy everything
firebase deploy
```

## 📂 Project Structure

- `functions/src/`: Contains all Cloud Functions logic (triggers, APIs).
- `firestore.rules`: Security rules for the Firestore database.
- `storage.rules`: Security rules for Firebase Cloud Storage.
