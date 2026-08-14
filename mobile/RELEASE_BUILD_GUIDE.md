# Real Estate Platform - Release Build Guide

This document provides instructions on how to generate a release build (APK/AAB) for the Real Estate Platform application.

## Prerequisites

- **Flutter version**: Use the version defined in FVM (e.g., run `fvm flutter --version`).
- **Android SDK**: Ensure the Android SDK is installed and configured in your environment.
- **Java/JDK**: JDK 17+ is recommended.
- **Gradle**: The project is configured with a compatible Gradle version using the Android Gradle Plugin.

## Firebase Production Setup

This project uses Firebase as the primary backend. Ensure that you have the correct production configurations in place:

- **Android**: Verify `android/app/google-services.json` is linked to your production Firebase project.
- **iOS**: Verify `ios/Runner/GoogleService-Info.plist` is linked to your production Firebase project.

## Android Signing Configuration

The Android project is configured to automatically use the release keystore when building in `--release` mode.

1. Ensure the `upload-keystore.jks` exists in the `android/` directory (DO NOT commit this file).
2. Ensure `android/key.properties` exists with the following values:
   ```properties
   storePassword=<your_store_password>
   keyPassword=<your_key_password>
   keyAlias=<your_key_alias>
   storeFile=upload-keystore.jks
   ```
3. NEVER commit `key.properties` to version control. It is already ignored in `.gitignore`.

For more details on Android Signing and the keystore, see [ANDROID_SIGNING.md](./ANDROID_SIGNING.md).

## Generating Release Builds

Before building, always clean the project and fetch dependencies:
```bash
fvm flutter clean
fvm flutter pub get
```

### Build APK (for testing on device)
```bash
fvm flutter build apk --release --dart-define=PAYMENT_ENV=production
```
The output APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

### Build App Bundle (AAB - for Google Play Store upload)
```bash
fvm flutter build appbundle --release --dart-define=PAYMENT_ENV=production
```
The output AAB will be located at:
`build/app/outputs/bundle/release/app-release.aab`

## Google Play App Signing Setup

When you upload the generated AAB to the Google Play Console for the first time, you must opt-in to **Google Play App Signing**. 
Google will use the upload key (your JKS file) to verify your identity, and will sign the final APKs distributed to users with a separate production key managed by Google.

## Required Client Credentials

You may pass additional client-safe configuration via `--dart-define` at build time if they aren't hardcoded in the constants:
- `PAYMENT_ENV`: Use `production` for real payments, `sandbox` for mock payments.
- `PAYMENT_PUBLIC_KEY`: The client-safe public key for your payment gateway.
- `GOOGLE_MAPS_API_KEY`: Client-safe restricted Maps API key.

## iOS Release Requirements

For iOS, you must configure the release settings in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Select the `Runner` project in the navigator.
3. Under the **Signing & Capabilities** tab, select your team and configure the provisioning profile.
4. Update the **Bundle Identifier**, **Version**, and **Build** as required.
5. Create an archive by selecting **Product > Archive**.
6. Ensure that the required permissions (e.g. Location, Camera, Notifications) are properly described in `Info.plist`. The app has been audited to only include necessary permissions.

## Common Release Issues

- **Build Failure due to minification (R8)**: If the app crashes in release mode but works in debug mode, it's likely an issue with R8 minification stripping out required classes. Ensure `android/app/proguard-rules.pro` contains necessary keep rules for your dependencies (e.g., Firebase, Google Maps).
- **Missing google-services.json**: Ensure the `google-services.json` file is present in `android/app/`.
- **Keystore Not Found**: Ensure `upload-keystore.jks` and `key.properties` are in the correct location (`android/`).
