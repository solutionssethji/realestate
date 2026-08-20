# Real Estate Platform - Customer Mobile App 📱

Built with **Flutter** for iOS and Android.
Uses **Riverpod** for state management and Firebase SDKs for backend communication.
Features a premium UI with theming, Google Maps integration, and bilingual support (English/Hindi).

## Local Development 🚀
```bash
cd mobile
flutter clean
flutter pub get
flutter run
```

## Deployment Guide

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

## Testing 🧪
- **Flutter**: `fvm flutter test` & `fvm flutter analyze`
