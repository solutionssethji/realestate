# Real Estate Platform 🏡

A complete End-to-End Real Estate Platform containing a Customer Flutter Mobile Application, a robust Node.js/Express Backend, and a Next.js Admin Panel CRM. 

This platform allows customers to view real estate projects, check plot availability, calculate EMIs, book site visits, and make initial payments. Administrators can manage the entire property catalog and monitor leads via a modern CRM dashboard.

## Architecture 🏗️

The project is structured into three main directories:

1. **/mobile (Customer App)**
   - Built with **Flutter** for iOS and Android.
   - Uses **Riverpod** for state management and **Dio** for API communication.
   - Features a premium UI with theming, 360° virtual tours (mocked), Google Maps integration, and bilingual support (English/Hindi).

2. **/backend (API & Database)**
   - Built with **Node.js, Express, and TypeScript**.
   - Uses **Prisma** ORM with SQLite (development) or PostgreSQL (production).
   - Features robust JWT authentication, Zod input validation, and a mock payment gateway webhook flow.

3. **/admin (CRM Panel)**
   - Built with **Next.js (App Router)** and React.
   - Uses **TailwindCSS** for styling and standard fetch APIs for data retrieval.
   - Fully responsive CRUD dashboard for managing Projects, Plots, Offers, Enquiries, Site Visits, and Payments.

## Local Development 🚀

### 1. Start the Backend
```bash
cd backend
npm install
# Seed the database with mock data and admin user
npm run seed
npm run dev
```
*API will run on `http://localhost:3001`*

### 2. Start the Admin Panel
```bash
cd admin
npm install
npm run dev
```
*Panel will run on `http://localhost:3000`*

### 3. Start the Customer App
```bash
cd mobile
flutter pub get
flutter run
```

## Documentation & Handover
- **[Deployment Guide](DEPLOYMENT_GUIDE.md)**: Steps to push the platform to production.
- **[Client Inputs Required](CLIENT_INPUTS_REQUIRED.md)**: Assets and keys needed to finalize production.

## Testing 🧪
- **Flutter**: `fvm flutter test` & `fvm flutter analyze`
- **Backend**: `npm run test` & `npm run lint`
- **Admin**: `npm run lint` & `npm run build`
