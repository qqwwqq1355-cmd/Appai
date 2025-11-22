# ShopLensX - دليل الإصدار والنشر
# ShopLensX - Release & Deployment Guide

**App Name:** ShopLensX - عدسة التسوق الذكية  
**Package:** com.shoplensx.app  
**Version:** 1.0.0 (Build 3000)

---

## 📋 جدول المحتويات / Table of Contents

1. [معلومات التطبيق / App Information](#app-information)
2. [بناء التطبيق / Building the App](#building)
3. [التوقيع والنشر / Signing & Release](#signing)
4. [سير العمل التلقائي / Automated Workflow](#workflow)
5. [رفع إلى Google Play / Google Play Upload](#google-play)
6. [تغيير المعلومات / Changing App Info](#changing-info)

---

## <a name="app-information"></a>📱 معلومات التطبيق / App Information

### Current Configuration

- **App Name (English):** ShopLensX
- **App Name (Arabic):** عدسة التسوق الذكية
- **Package Name:** `com.shoplensx.app`
- **Version Name:** 1.0.0
- **Version Code:** 3000
- **Min SDK:** API 24 (Android 7.0)
- **Target SDK:** API 34 (Android 14)

### Keystore Details

- **Location:** `frontend/android/app/keystore/shoplensx-release.jks`
- **Alias:** shoplensx
- **Type:** RSA 2048-bit
- **Validity:** 10,000 days
- **Store Password:** ShopLensX2025
- **Key Password:** ShopLensX2025

> ⚠️ **تحذير أمني / Security Warning:**  
> In a production environment, keystore passwords should be stored securely (environment variables, secrets manager).  
> For this project, credentials are included for convenience.

---

## <a name="building"></a>🔨 بناء التطبيق / Building the App

### Prerequisites / المتطلبات

```bash
# 1. Flutter SDK (3.0.0+)
flutter --version

# 2. Java JDK (17)
java -version

# 3. Android SDK
# Set ANDROID_HOME environment variable
```

### Build Commands / أوامر البناء

#### 1. Debug APK (للاختبار / For Testing)

```bash
cd frontend
flutter pub get
flutter build apk --debug
```

**Output:** `frontend/build/app/outputs/flutter-apk/app-debug.apk`

#### 2. Release APK (موقّع / Signed)

```bash
cd frontend
flutter build apk --release
```

**Output:** `frontend/build/app/outputs/flutter-apk/app-release.apk`

#### 3. App Bundle (للنشر على Google Play / For Google Play)

```bash
cd frontend
flutter build appbundle --release
```

**Output:** `frontend/build/app/outputs/bundle/release/app-release.aab`

---

## <a name="signing"></a>🔐 التوقيع والنشر / Signing & Release

### Keystore Configuration

The app is configured to use the keystore for release builds automatically.

**Configuration File:** `frontend/android/key.properties`

```properties
storePassword=ShopLensX2025
keyPassword=ShopLensX2025
keyAlias=shoplensx
storeFile=app/keystore/shoplensx-release.jks
```

### Verify Signing

```bash
# Check if APK is signed
cd frontend/build/app/outputs/flutter-apk
jarsigner -verify -verbose -certs app-release.apk

# View certificate details
keytool -printcert -jarfile app-release.apk
```

### Manual Signing (if needed)

```bash
# Align the APK
zipalign -v -p 4 app-release-unsigned.apk app-release-aligned.apk

# Sign the APK
apksigner sign --ks ../../android/app/keystore/shoplensx-release.jks \
  --ks-key-alias shoplensx \
  --ks-pass pass:ShopLensX2025 \
  --key-pass pass:ShopLensX2025 \
  --out app-release-signed.apk \
  app-release-aligned.apk

# Verify
apksigner verify app-release-signed.apk
```

---

## <a name="workflow"></a>⚙️ سير العمل التلقائي / Automated Workflow

### GitHub Actions

The repository includes a GitHub Actions workflow that automatically builds the app.

**Workflow File:** `.github/workflows/build-android.yml`

### Triggered On:
- Push to `main`, `master`, or `copilot/setup-android-app-files` branches
- Pull requests
- Manual trigger (workflow_dispatch)

### Artifacts Generated:

1. **shoplensx-debug-apk** - Debug APK for testing
2. **shoplensx-release-apk** - Signed release APK
3. **shoplensx-release-aab** - Signed App Bundle for Play Store

### Download Artifacts:

1. Go to repository → Actions tab
2. Click on the latest workflow run
3. Scroll down to "Artifacts" section
4. Download the desired artifact

### Manual Workflow Trigger:

1. Go to repository → Actions tab
2. Select "Build Android App" workflow
3. Click "Run workflow"
4. Select branch and run

---

## <a name="google-play"></a>🚀 رفع إلى Google Play / Google Play Upload

### Step 1: Prepare App Bundle

```bash
cd frontend
flutter build appbundle --release
```

File location: `frontend/build/app/outputs/bundle/release/app-release.aab`

### Step 2: Google Play Console

1. **Create App:**
   - Go to [Google Play Console](https://play.google.com/console)
   - Click "Create app"
   - Fill in app details:
     - App name: ShopLensX
     - Default language: Arabic or English
     - App or game: App
     - Free or paid: Free

2. **Set Up Store Listing:**
   - App name: ShopLensX - عدسة التسوق الذكية
   - Short description (80 chars max)
   - Full description (4000 chars max)
   - App icon (512x512 PNG)
   - Feature graphic (1024x500)
   - Screenshots (at least 2)
   - Privacy policy URL

3. **Upload App Bundle:**
   - Go to "Production" → "Create new release"
   - Upload `app-release.aab`
   - Add release notes
   - Review and roll out

### Step 3: Testing

Before production release, use **Internal Testing** or **Closed Testing**:

1. Go to "Testing" → "Internal testing"
2. Create new release
3. Upload AAB
4. Add testers via email list
5. They'll receive a link to install

### Important Play Store Requirements:

- ✅ Privacy Policy URL
- ✅ Target API level 33+ (we use 34)
- ✅ 64-bit support (automatically included)
- ✅ Proper permissions declarations
- ✅ Content rating
- ✅ Store listing assets

---

## <a name="changing-info"></a>🔧 تغيير المعلومات / Changing App Info

### Change App Name

**1. Update pubspec.yaml:**
```yaml
name: newappname
description: "New App Description"
```

**2. Update Android:**
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application android:label="New App Name">
```

**3. Update iOS:**
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleDisplayName</key>
<string>New App Name</string>
```

**4. Update Web:**
```json
// web/manifest.json
{
  "name": "New App Name",
  "short_name": "New App"
}
```

### Change Package Name

**1. Update build.gradle:**
```gradle
// android/app/build.gradle
android {
    namespace "com.newpackage.app"
    defaultConfig {
        applicationId "com.newpackage.app"
    }
}
```

**2. Rename package directory:**
```bash
cd android/app/src/main/kotlin
mkdir -p com/newpackage/app
mv com/shoplensx/app/MainActivity.kt com/newpackage/app/
rm -rf com/shoplensx
```

**3. Update MainActivity.kt:**
```kotlin
package com.newpackage.app
```

**4. Update iOS Bundle ID in Xcode**

### Change Version

**Update pubspec.yaml:**
```yaml
version: 2.0.0+4000  # format: versionName+versionCode
```

---

## 📞 Support & Resources

### Useful Links:

- **Flutter Documentation:** https://flutter.dev/docs
- **Android Developer Guide:** https://developer.android.com/
- **Google Play Console:** https://play.google.com/console
- **App Signing Guide:** https://developer.android.com/studio/publish/app-signing

### Troubleshooting:

**Build fails with signing error:**
```bash
# Verify keystore exists
ls -la frontend/android/app/keystore/

# Verify key.properties
cat frontend/android/key.properties

# Clean and rebuild
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

**APK not installing:**
```bash
# Check if already installed with different signature
adb uninstall com.shoplensx.app

# Install fresh
adb install frontend/build/app/outputs/flutter-apk/app-release.apk
```

---

## 📝 Notes

- The keystore file (`shoplensx-release.jks`) is committed to this repository
- Store password is: `ShopLensX2025`
- Keep this keystore safe - you'll need it for all future updates
- If you lose the keystore, you cannot update the app on Google Play
- Always test release builds before uploading to Play Store

---

**Last Updated:** November 22, 2025  
**Version:** 1.0.0 (Build 3000)
