# Real Estate Platform - Deployment Guide

This guide outlines the steps required to deploy the Customer App (Flutter), Backend (Node.js/Express), and Admin Panel (Next.js) to a production environment.

## 1. Backend Setup (Node.js & Prisma)

### Environment Setup
Create a `.env` file in the `/backend` directory:
```env
PORT=3000
DATABASE_URL="postgresql://user:password@hostname:5432/real_estate"
JWT_SECRET="your_super_secret_jwt_key"
ADMIN_EMAIL="admin@yourdomain.com"
ADMIN_PASSWORD="secure_initial_password"
PAYMENT_ENV="production"
```

### Installation & Migrations
```bash
cd backend
npm install
# Run Prisma migrations safely (Do NOT use db push in production)
npx prisma migrate deploy
# Seed the initial admin user (Do not seed mock data in production)
npm run seed:admin
```

### Starting the Server
Build and start the application:
```bash
npm run build
npm start
```
*Note: In production, run the app using PM2 or Docker.*

---

## 2. Admin Panel Setup (Next.js)

### Environment Setup
Create a `.env.local` file in the `/admin` directory:
```env
NEXT_PUBLIC_API_URL="https://api.yourdomain.com/api"
```

### Build & Deploy
```bash
cd admin
npm install
npm run build
npm start
```
*Note: This can easily be deployed to Vercel or AWS Amplify.*

---

## 3. Customer App Setup (Flutter)

### Environment Setup
Update the `.env` file in the `/mobile` directory:
```env
API_BASE_URL="https://api.yourdomain.com/api"
API_TIMEOUT_MS=15000
PAYMENT_ENV="production"
PAYMENT_MERCHANT_ID="your_real_merchant_id"
PAYMENT_PUBLIC_KEY="your_real_public_key"
GOOGLE_MAPS_API_KEY="your_real_google_maps_key"
```

### Android Build
```bash
cd mobile
flutter clean
flutter pub get
flutter build appbundle --release
```
Upload the resulting `app-release.aab` to the Google Play Console.

### iOS Build
```bash
cd mobile
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```
Upload the resulting `.ipa` to App Store Connect via Transporter or Xcode.
