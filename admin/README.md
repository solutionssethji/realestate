# Real Estate Platform - Admin CRM Panel 🏡

Built with **Next.js (App Router)** and React. Uses **TailwindCSS** for styling and standard fetch APIs for data retrieval.
Fully responsive CRUD dashboard for managing Projects, Plots, Offers, Enquiries, Site Visits, and Payments.

## Local Development 🚀
```bash
cd admin
npm install
npm run dev
```
*Panel will run on `http://localhost:3000`*

## Deployment Guide
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

## Testing 🧪
- `npm run lint` & `npm run build`
