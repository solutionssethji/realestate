# Real Estate Platform - Backend (Firebase) 🏗️

This folder contains the complete Firebase backend for the Real Estate Platform, including Firestore security rules, Storage rules, and Cloud Functions.

## Local Development 🚀
```bash
cd backend/functions
npm install
npm run dev
```

## Deployment Guide
### Environment Setup
The backend relies on the Firebase CLI. Ensure you are logged into the correct Firebase project using `firebase login` and `firebase use <project-id>`.

### Installation
```bash
cd backend/functions
npm install
```

### Deploying Rules
To deploy the Firestore security rules:
```bash
npx firebase-tools deploy --only firestore:rules
```

### Deploying Functions
To deploy the Firebase Cloud Functions:
```bash
cd functions
npm run deploy
```

## Testing 🧪
- `npm run lint` within the `functions` directory.
