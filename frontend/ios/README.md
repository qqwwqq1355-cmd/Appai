# ShopLensX iOS Platform

This directory contains the iOS-specific code and configuration for the ShopLensX Flutter application.

## Structure

```
ios/
├── Runner/
│   ├── Assets.xcassets/
│   │   ├── AppIcon.appiconset/      # App icons
│   │   └── LaunchImage.imageset/    # Launch screen image
│   ├── Base.lproj/
│   │   ├── LaunchScreen.storyboard  # Launch screen
│   │   └── Main.storyboard          # Main storyboard
│   ├── AppDelegate.swift            # App delegate
│   ├── Info.plist                   # App configuration & permissions
│   └── Runner-Bridging-Header.h     # Objective-C bridge
├── Runner.xcodeproj/                # Xcode project
├── Runner.xcworkspace/              # Xcode workspace
└── Podfile                          # CocoaPods dependencies
```

## Configuration

### Application Details
- **Bundle Identifier**: `com.shoplensx.app` (configured in Xcode)
- **Deployment Target**: iOS 12.0+
- **Display Name**: ShopLensX

### Permissions
The app requires the following permissions (configured in Info.plist):
- `NSCameraUsageDescription` - "ShopLensX needs camera access to scan products and get price comparisons."
- `NSPhotoLibraryUsageDescription` - "ShopLensX needs photo library access to select product images."
- `NSPhotoLibraryAddUsageDescription` - "ShopLensX needs permission to save product images."

### Supported Orientations
- **iPhone**: Portrait, Landscape Left, Landscape Right
- **iPad**: All orientations including Portrait Upside Down

## Building

### Requirements
- macOS
- Xcode 14.0 or higher
- CocoaPods

### Setup
```bash
cd ios
pod install
cd ..
```

### Debug Build
```bash
flutter build ios --debug --no-codesign
```

### Release Build
```bash
flutter build ios --release
```

Note: Release builds require:
- Apple Developer Account
- Valid provisioning profile
- Code signing certificate

## CocoaPods

The project uses CocoaPods for dependency management. All Flutter plugins are automatically integrated.

### Update Pods
```bash
cd ios
pod update
cd ..
```

### Clean Pods
```bash
cd ios
pod deintegrate
pod install
cd ..
```

## Assets

### App Icons
Located in `Runner/Assets.xcassets/AppIcon.appiconset/`

Icon sizes included:
- 20x20 (@1x, @2x, @3x)
- 29x29 (@1x, @2x, @3x)
- 40x40 (@1x, @2x, @3x)
- 60x60 (@2x, @3x)
- 76x76 (@1x, @2x)
- 83.5x83.5 (@2x)
- 1024x1024 (@1x) - App Store

### Launch Images
Located in `Runner/Assets.xcassets/LaunchImage.imageset/`
- LaunchImage.png (@1x, @2x, @3x)

## Xcode Configuration

### Opening in Xcode
```bash
open ios/Runner.xcworkspace
```

**Important**: Always open `.xcworkspace`, not `.xcodeproj`

### Build Settings
- **Deployment Target**: 12.0
- **Swift Version**: 5.0+
- **Signing**: Configure in Xcode → Runner → Signing & Capabilities

## Swift Code

### AppDelegate.swift
The main entry point for the iOS app. Registers Flutter plugins and handles app lifecycle.

```swift
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Troubleshooting

### CocoaPods Issues
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Xcode Build Failed
1. Clean build folder: Xcode → Product → Clean Build Folder
2. Restart Xcode
3. Try:
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### Signing Issues
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Select Runner target
3. Go to Signing & Capabilities
4. Select your team and configure signing

### Simulator Not Found
```bash
# List available simulators
xcrun simctl list devices

# Boot a simulator
xcrun simctl boot "iPhone 14"

# Or use Xcode to open Simulator
open -a Simulator
```

## Custom Configuration

### Change Bundle Identifier
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Change Bundle Identifier in General tab
4. Update `PRODUCT_BUNDLE_IDENTIFIER` in build settings

### Change Display Name
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Change Display Name in General tab
4. Or edit `CFBundleDisplayName` in `Info.plist`

### Add Capabilities
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Click "+ Capability" to add features like:
   - Push Notifications
   - Background Modes
   - In-App Purchase
   - etc.

## Integration

### Google ML Kit
iOS uses Firebase ML Kit. Dependencies are managed via CocoaPods and configured automatically.

### Camera
Uses the Flutter camera plugin. iOS permissions are configured in `Info.plist`.

### Future AR Features
The app is prepared for AR integration with ARKit. No additional configuration needed for basic AR features.

## App Store Submission

### Prepare for Release
1. Update version in `pubspec.yaml`
2. Build release version:
```bash
flutter build ios --release
```
3. Open Xcode and archive:
   - Xcode → Product → Archive
4. Upload to App Store Connect
5. Submit for review

### Required Assets
- App icon (1024x1024)
- Screenshots for various device sizes
- Privacy policy URL
- App description

### App Store Requirements
- Privacy manifest
- Camera usage description
- Photo library usage description
- All required icons
- Launch screen

## Resources
- [Flutter iOS Setup](https://flutter.dev/docs/get-started/install/macos#ios-setup)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [CocoaPods Guide](https://guides.cocoapods.org/)
- [Xcode Help](https://help.apple.com/xcode/)
