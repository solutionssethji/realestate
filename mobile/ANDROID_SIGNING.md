# Android Signing Guide

This document explains the Android app signing configuration for the Real Estate Platform.

## The Keystore

A Java Keystore (`upload-keystore.jks`) has been generated and placed in the `android/` directory.

- **Purpose**: This keystore is used as the **Upload Key** for the Google Play Store. It is used to sign the App Bundle (AAB) before uploading it to the Play Console.
- **Location**: `android/upload-keystore.jks`
- **Security**: This file **MUST NEVER BE COMMITTED TO GIT**. It has already been added to `.gitignore`.

## Key Properties Configuration

To securely provide the keystore passwords to the Gradle build system without hardcoding them in the `build.gradle` file, we use a properties file.

- **Location**: `android/key.properties`
- **Security**: This file contains plain-text passwords and **MUST NEVER BE COMMITTED TO GIT**. It has already been added to `.gitignore`.

### Contents of `key.properties`
The file should contain the following properties. (The actual passwords should be securely provided by the project owner/developer and kept in a password manager).
```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=<your_key_alias>
storeFile=upload-keystore.jks
```

## How Signing is Configured

In `android/app/build.gradle.kts`, the signing configuration is set up to read from `key.properties`:

```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

This ensures that whenever a release build is triggered (e.g. `fvm flutter build appbundle --release`), Gradle will automatically use the upload keystore to sign the application.

## Backing Up the Keystore

It is highly recommended to securely back up `upload-keystore.jks` and the credentials inside `key.properties`.
- Use a secure password manager (e.g. 1Password, Bitwarden) or a secure enterprise vault.
- If you lose the upload key, you will need to contact Google Play Developer Support to reset it, which can cause delays in publishing updates.

## Google Play App Signing

Google Play requires **App Signing by Google Play** for new apps. 
This means:
1. You sign your AAB with the `upload-keystore.jks`.
2. You upload the signed AAB to the Play Console.
3. Google Play verifies the signature, then strips it and re-signs the APKs with the actual **App Signing Key** (which is securely managed by Google's infrastructure).

The `upload-keystore.jks` we created acts as the upload key in this process.
