# ShopLensX - Build Instructions

## Prerequisites

### For Android Development
- **Flutter SDK**: Version 3.10.0 or higher
- **Android Studio** or **Android SDK Command-line Tools**
- **Java JDK**: Version 11 or higher (17 recommended)
- **Android SDK**: API Level 24 (Android 7.0) or higher
  - Target SDK: API Level 34

### For iOS Development
- **macOS**: Required for iOS builds
- **Xcode**: 14.0 or higher
- **CocoaPods**: For dependency management
- **iOS Deployment Target**: 12.0 or higher

### For Web Development
- **Flutter SDK** with web support enabled

## Setup Instructions

### 1. Install Flutter
```bash
# Download Flutter SDK
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor -v
```

### 2. Get Dependencies
```bash
cd frontend
flutter pub get
```

### 3. Android Setup

#### Install Android SDK
```bash
# Download Android command-line tools from:
# https://developer.android.com/studio#command-tools

# Set environment variables
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Install required SDK components
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

#### Configure Local Properties
Create `android/local.properties`:
```properties
sdk.dir=/path/to/your/Android/Sdk
flutter.sdk=/path/to/your/flutter
```

### 4. iOS Setup (macOS only)
```bash
cd ios
pod install
cd ..
```

## Building the Application

### Android

#### Debug Build (APK)
```bash
flutter build apk --debug
```

#### Release Build (APK)
```bash
flutter build apk --release
```

#### Release Build (App Bundle for Play Store)
```bash
flutter build appbundle --release
```

Output locations:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

### iOS

#### Debug Build
```bash
flutter build ios --debug --no-codesign
```

#### Release Build
```bash
flutter build ios --release
```

Note: For iOS release builds, you need:
- Apple Developer Account
- Valid provisioning profile
- Code signing certificate

### Web

```bash
flutter build web --release
```

Output: `build/web/`

## Running the Application

### Android Emulator
```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run
```

### iOS Simulator (macOS only)
```bash
open -a Simulator
flutter run
```

### Chrome (Web)
```bash
flutter run -d chrome
```

## Required Permissions

### Android Permissions (Configured in AndroidManifest.xml)
- ✅ CAMERA - For product scanning
- ✅ INTERNET - For API calls
- ✅ READ_MEDIA_IMAGES - For accessing gallery
- ✅ ACCESS_NETWORK_STATE - For network monitoring

### iOS Permissions (Configured in Info.plist)
- ✅ NSCameraUsageDescription - Camera access
- ✅ NSPhotoLibraryUsageDescription - Photo library access
- ✅ NSPhotoLibraryAddUsageDescription - Save images

## Build Configurations

### Application ID
- Android: `com.shoplensx.app`
- iOS: Should match your bundle identifier

### Version Information
- Version: `1.0.0+1`
- Version Code: `1`
- Version Name: `1.0`

### Minimum SDK Versions
- Android: API 24 (Android 7.0)
- iOS: iOS 12.0

### Target SDK Versions
- Android: API 34 (Android 14)
- iOS: Latest

## Troubleshooting

### Common Issues

#### 1. Gradle Build Failed
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 2. Cocoapods Issues
```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### 3. Flutter Doctor Issues
```bash
flutter doctor -v
# Follow the instructions for missing components
```

#### 4. Gradle Wrapper Missing
The `gradlew` wrapper is included. If missing:
```bash
cd android
gradle wrapper --gradle-version 8.3
cd ..
```

## Environment Variables

Create a `.env` file in the frontend root:
```env
API_BASE_URL=https://api.shoplensx.app
GOOGLE_ML_KIT_API_KEY=your_key_here
# Add other API keys as needed
```

## Release Signing (Android)

### Generate Keystore
```bash
keytool -genkey -v -keystore ~/shoplensx-release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias shoplensx
```

### Create key.properties
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=shoplensx
storeFile=/path/to/shoplensx-release.keystore
```

**Important**: Never commit `key.properties` or keystore files to version control!

## Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter drive --target=test_driver/app.dart
```

### Build Tests
```bash
# Test Android build
flutter build apk --debug

# Test iOS build (macOS only)
flutter build ios --debug --no-codesign
```

## CI/CD

Example GitHub Actions workflow is available in `.github/workflows/`.

## Support

For issues or questions:
- Check Flutter documentation: https://flutter.dev/docs
- ShopLensX issues: https://github.com/qqwwqq1355-cmd/Appai/issues

---

**Last Updated**: November 2025
**Flutter Version**: 3.10.0+
