# Client Inputs Required

The following assets and credentials are required from the client to move the Real Estate Platform into full production. The application is fully functional but currently relies on mock placeholders for these specific integrations.

| Item | Current Status | Where It Is Used | Required Format |
|---|---|---|---|
| **Logo & Branding Assets** | Placeholder text/colors used | Flutter App (Splash, Home) & Admin Panel | High-res PNG/SVG (transparent background) & Primary HEX Color Codes |
| **Real Project Images** | Unsplash mock placeholders | Flutter App (Project Details, Offers) | High-quality JPG/PNG, optimized for mobile |
| **Real Project & Plot Data** | Mock mock data seeded in DB | Database / Admin CRM | Excel/CSV sheet with actual plot sizes, prices, statuses |
| **Site Layout Image** | Missing | Flutter App (Plot Availability) | High-res image (e.g. `layout.png`) of the master plan |
| **360° Videos** | Mock video URL used | Flutter App (Project Details) | YouTube Links or MP4 hosted URLs for panoramic tours |
| **Payment Gateway Credentials** | `MOCK` Gateway | Backend API (`/payments`) & Flutter App | Razorpay/Stripe API Keys (Merchant ID, Public Key, Secret Key) |
| **Google Maps API Key** | Placeholder used | Flutter App (Location Maps) | Google Cloud Platform API Key with Maps SDK for Android/iOS enabled |
| **Hosting & Domain Credentials** | Localhost used | Deployment | AWS / Vercel / DigitalOcean credentials & Custom Domain Name |
| **SMTP / Email Credentials** | Mock console.log used | Backend API (Forgot Password) | SMTP Host, Port, User, Password (e.g., SendGrid, AWS SES) |

## Instructions for Integration
1. **App Assets**: Replace `mobile/assets/` images when final logos are received.
2. **Environment Variables**: Add the real API keys into the production `.env` files for both the Backend and the Mobile App.
3. **Database Seed**: Clear the development mock data and seed real plots using the Admin Panel.
