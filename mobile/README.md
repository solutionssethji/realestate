# Shubhaytanam Connect - Customer Mobile App 📱

The customer-facing mobile application for Shubhaytanam Connect, built with **Flutter**.
It uses **Riverpod** for state management and connects directly to **Firebase** (Auth, Firestore, Storage) for backend services.

Features a premium UI, bilingual support (English/Hindi), property discovery, and site visit bookings.

## 🚀 Local Development

```bash
# Navigate to the mobile directory
cd mobile

# Clean and fetch dependencies
flutter clean
flutter pub get

# Run the app
flutter run
```

## ⚙️ Configuration

Firebase configuration is managed via `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
- Ensure these files are placed in their respective `android/app` and `ios/Runner` directories.
- The `lib/firebase_options.dart` file handles Dart-side Firebase initialization.

## 📦 Deployment Guide

### Android Build
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```
Upload the resulting `build/app/outputs/bundle/release/app-release.aab` to the Google Play Console.

### iOS Build
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release
```
Upload the resulting `.ipa` to App Store Connect via Transporter or Xcode.

## 🧪 Testing
- **Format Code**: `flutter format lib/`
- **Analyze Code**: `flutter analyze`
