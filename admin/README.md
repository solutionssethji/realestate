# Shubhaytanam Connect - Admin Dashboard 💻

The administration dashboard for the Shubhaytanam Connect real estate platform, built with **Next.js (App Router)**, **React**, and **Tailwind CSS**. It connects directly to **Firebase (Firestore)** for data management.

This dashboard allows administrators to manage:
- Projects & Properties
- Plot Inventory & Pricing
- Customer Enquiries
- Site Visits & Bookings
- Application Settings

## 🚀 Local Development

```bash
# Navigate to the admin directory
cd admin

# Install dependencies
npm install

# Start the development server
npm run dev
```

*The dashboard will run on `http://localhost:3000`*

## ⚙️ Configuration

Firebase configuration is managed via `src/lib/firebase.ts`. Ensure your Firebase project settings (API keys, project ID, etc.) are properly configured.

To use Firebase Emulators during development, set `USE_FIREBASE_EMULATORS = true` in the Firebase config file.

## 📦 Build & Deploy

This project can be seamlessly deployed to platforms like **Vercel**, **AWS Amplify**, or **Firebase Hosting**.

```bash
# Build the production application
npm run build

# Start the production server locally
npm start
```

## 🧪 Testing

```bash
npm run lint
```
