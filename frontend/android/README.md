# MarketLens Android Platform

This directory contains the Android-specific code and configuration for the MarketLens Flutter application.

## Structure

```
android/
├── app/
│   ├── src/main/
│   │   ├── kotlin/com/marketlens/app/
│   │   │   └── MainActivity.kt          # Main Android activity
│   │   ├── res/                         # Android resources
│   │   │   ├── drawable/                # Drawable resources
│   │   │   ├── mipmap-*/               # App icons (various densities)
│   │   │   └── values/                 # Styles and themes
│   │   └── AndroidManifest.xml         # App manifest with permissions
│   ├── build.gradle                    # App-level build configuration
│   └── proguard-rules.pro             # ProGuard rules for release builds
├── gradle/
│   └── wrapper/                        # Gradle wrapper files
├── build.gradle                        # Project-level build configuration
├── gradle.properties                   # Gradle configuration
├── settings.gradle                     # Gradle settings
└── local.properties.example           # Template for local configuration

```

## Configuration

### Application Details
- **Package Name**: `com.marketlens.app`
- **Min SDK**: API 24 (Android 7.0)
- **Target SDK**: API 34 (Android 14)
- **Compile SDK**: API 34

### Permissions
The app requires the following permissions (configured in AndroidManifest.xml):
- `CAMERA` - For product scanning
- `INTERNET` - For API communication
- `READ_MEDIA_IMAGES` - For accessing photos (Android 13+)
- `READ_EXTERNAL_STORAGE` - For accessing photos (Android 12 and below)
- `WRITE_EXTERNAL_STORAGE` - For saving images (Android 12 and below)
- `ACCESS_NETWORK_STATE` - For network monitoring

### Features
- Hardware camera (optional, app will work without it)
- Camera autofocus (optional)
- AR capabilities (optional, for future AR features)

## Build Configuration

### Kotlin Version
- Kotlin: 1.9.10

### Gradle
- Gradle: 8.3
- Android Gradle Plugin: 8.1.0

### Dependencies
- AndroidX MultiDex support
- Flutter embedding v2

## Building

### Debug Build
```bash
cd frontend
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
# or for Play Store
flutter build appbundle --release
```

### Output Locations
- APK: `build/app/outputs/flutter-apk/`
- App Bundle: `build/app/outputs/bundle/release/`

## ProGuard
ProGuard is enabled for release builds with optimizations. The `proguard-rules.pro` file contains:
- Flutter-specific keep rules
- Google ML Kit keep rules
- Camera library keep rules
- Retrofit/OkHttp keep rules

## Local Development

1. Copy `local.properties.example` to `local.properties`
2. Update the paths in `local.properties`:
   ```properties
   sdk.dir=/path/to/your/Android/Sdk
   flutter.sdk=/path/to/your/flutter
   ```

## Gradle Tasks

```bash
# Clean build
./gradlew clean

# Build debug APK
./gradlew assembleDebug

# Build release APK
./gradlew assembleRelease

# Run tests
./gradlew test
```

## Troubleshooting

### Gradle Sync Failed
```bash
./gradlew clean
flutter clean
flutter pub get
```

### MultiDex Issues
The app is configured with MultiDex support. If you encounter DEX limit issues, ensure:
- `multiDexEnabled true` is in build.gradle
- MultiDex dependency is included

### SDK License Issues
```bash
yes | sdkmanager --licenses
```

## Custom Configuration

### Change Package Name
1. Update `namespace` in `app/build.gradle`
2. Update `package` in `AndroidManifest.xml`
3. Rename Kotlin package directories
4. Update package in `MainActivity.kt`

### Change App Name
Update the `android:label` in `AndroidManifest.xml`

### Change App Icon
Replace images in `res/mipmap-*` directories with your custom icons

## Integration

### Google ML Kit
The app is configured to use Google ML Kit for:
- Barcode scanning
- Text recognition (OCR)
- Image labeling
- Face detection

ML Kit dependencies are downloaded on-demand by Google Play Services.

### Camera
Uses the Flutter camera plugin. Configuration is handled automatically by Flutter.

## Release Signing

For release builds, you need to configure signing:

1. Generate a keystore:
```bash
keytool -genkey -v -keystore ~/marketlens-release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 -alias marketlens
```

2. Create `key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=marketlens
storeFile=/path/to/marketlens-release.keystore
```

3. Update `app/build.gradle` to reference `key.properties`

**Important**: Never commit signing keys to version control!

## Resources
- [Flutter Android Setup](https://flutter.dev/docs/get-started/install/macos#android-setup)
- [Android Developer Guide](https://developer.android.com/guide)
- [Gradle Build Guide](https://docs.gradle.org/current/userguide/userguide.html)
