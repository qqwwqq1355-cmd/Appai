# Phase 4B & 4C Implementation Guide

## Overview

This document provides complete instructions for implementing:
- **Phase 4B:** Firebase, AdMob, Google Play Billing, OAuth
- **Phase 4C:** Localization (Arabic + English + RTL)

---

## Phase 4B: External Services Integration

### 1. Firebase Setup

#### 1.1 Add Dependencies
Update `frontend/pubspec.yaml`:
```yaml
dependencies:
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  firebase_analytics: ^11.3.3
  firebase_crashlytics: ^4.1.3
  firebase_messaging: ^15.1.3
  firebase_remote_config: ^5.1.3
  cloud_firestore: ^5.4.4
```

#### 1.2 Firebase Console Setup
1. Go to https://console.firebase.google.com
2. Create new project "MarketLens"
3. Add Android app:
   - Package name: `com.marketlens.app`
   - Download `google-services.json`
   - Place in `frontend/android/app/`
4. Add iOS app (if needed):
   - Bundle ID: `com.marketlens.app`
   - Download `GoogleService-Info.plist`
   - Place in `frontend/ios/Runner/`

#### 1.3 Android Configuration
Update `frontend/android/build.gradle`:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Update `frontend/android/app/build.gradle`:
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 23  // For Android 7+
        targetSdkVersion 34  // Latest
    }
}
```

#### 1.4 Initialize Firebase
Create `frontend/lib/services/firebase_service.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    
    // Messaging
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    
    // Remote Config
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await remoteConfig.fetchAndActivate();
  }
  
  static FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.messageId}');
}
```

Update `frontend/lib/main.dart`:
```dart
import 'package:marketlens/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const MyApp());
}
```

---

### 2. AdMob Integration

#### 2.1 Add Dependencies
```yaml
dependencies:
  google_mobile_ads: ^5.2.0
```

#### 2.2 AdMob Console Setup
1. Go to https://apps.admob.google.com
2. Create app "MarketLens"
3. Create ad units:
   - Banner Ad (Home, Details, Comparison)
   - Native Ad (Product lists)
   - Interstitial Ad (Between screens)
   - Rewarded Video Ad (Optional)
4. Note all ad unit IDs

#### 2.3 Configure Ad Unit IDs
Add to Firebase Remote Config or create `frontend/lib/config/ad_config.dart`:
```dart
class AdConfig {
  static const String bannerAdUnitId = 'ca-app-pub-xxxxx/xxxxx'; // Replace
  static const String nativeAdUnitId = 'ca-app-pub-xxxxx/xxxxx';
  static const String interstitialAdUnitId = 'ca-app-pub-xxxxx/xxxxx';
  static const String rewardedAdUnitId = 'ca-app-pub-xxxxx/xxxxx';
  
  // Test IDs for development
  static const String testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';
}
```

#### 2.4 Initialize AdMob
Update `main.dart`:
```dart
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await MobileAds.instance.initialize();
  runApp(const MyApp());
}
```

#### 2.5 Create Ad Widgets
Create `frontend/lib/widgets/banner_ad_widget.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: AdConfig.testBannerAdUnitId, // Use real ID in production
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const SizedBox(height: 60);
    }
    return SizedBox(
      height: 60,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
```

#### 2.6 Replace Ad Placeholders
In all screens, replace:
```dart
// OLD
Container(
  height: 60,
  decoration: BoxDecoration(
    color: theme.colorScheme.surfaceVariant,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Center(
    child: Text('Banner Ad'),
  ),
),

// NEW
const BannerAdWidget(),
```

---

### 3. Google Play Billing

#### 3.1 Add Dependencies
```yaml
dependencies:
  in_app_purchase: ^3.2.0
```

#### 3.2 Google Play Console Setup
1. Go to https://play.google.com/console
2. Create app "MarketLens"
3. Setup billing:
   - Go to Monetize → Products → Subscriptions
   - Create subscription: "premium_monthly"
   - Price: $4.99/month
   - Benefits: Ad-free, unlimited scans
4. Note subscription ID

#### 3.3 Create Billing Service
Create `frontend/lib/services/billing_service.dart`:
```dart
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class BillingService {
  static final InAppPurchase _instance = InAppPurchase.instance;
  static const String premiumMonthlyId = 'premium_monthly';
  
  static Future<bool> isSubscribed() async {
    if (!await _instance.isAvailable()) return false;
    
    final response = await _instance.queryPastPurchases();
    return response.pastPurchases.any((purchase) => 
      purchase.productID == premiumMonthlyId && 
      purchase.status == PurchaseStatus.purchased
    );
  }
  
  static Future<void> subscribe() async {
    final response = await _instance.queryProductDetails({premiumMonthlyId});
    if (response.productDetails.isEmpty) return;
    
    final product = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _instance.buyNonConsumable(purchaseParam: purchaseParam);
  }
  
  static Stream<List<PurchaseDetails>> get purchaseStream => _instance.purchaseStream;
}
```

#### 3.4 Add Subscription UI
In `profile_screen.dart`, add subscription card:
```dart
Card(
  child: ListTile(
    leading: const Icon(Icons.workspace_premium),
    title: const Text('Premium Subscription'),
    subtitle: const Text('\$4.99/month - Ad-free & unlimited'),
    trailing: ElevatedButton(
      onPressed: () async {
        await BillingService.subscribe();
      },
      child: const Text('Subscribe'),
    ),
  ),
),
```

---

### 4. OAuth Integration

#### 4.1 Add Dependencies
```yaml
dependencies:
  google_sign_in: ^6.2.1
  flutter_facebook_auth: ^7.1.1
```

#### 4.2 Google Sign-In Setup
1. Firebase Console → Authentication → Sign-in method
2. Enable Google
3. Add SHA-1 fingerprint (get from Android Studio)

#### 4.3 Create Auth Service
Create `frontend/lib/services/oauth_service.dart`:
```dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class OAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  
  static Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Google sign-in error: $e');
      return null;
    }
  }
  
  static Future<User?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) return null;
      
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );
      
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print('Facebook sign-in error: $e');
      return null;
    }
  }
}
```

#### 4.4 Update Login Screen
Add OAuth buttons to `login_screen.dart`:
```dart
// After email/password login button
const SizedBox(height: 16),
const Divider(),
const SizedBox(height: 16),
ElevatedButton.icon(
  onPressed: () async {
    final user = await OAuthService.signInWithGoogle();
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  },
  icon: const Icon(Icons.login),
  label: const Text('Sign in with Google'),
),
const SizedBox(height: 12),
ElevatedButton.icon(
  onPressed: () async {
    final user = await OAuthService.signInWithFacebook();
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  },
  icon: const Icon(Icons.facebook),
  label: const Text('Sign in with Facebook'),
),
```

---

## Phase 4C: Localization

### 1. Add Localization Packages

Update `pubspec.yaml`:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true
```

### 2. Create l10n Configuration

Create `frontend/l10n.yaml`:
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 3. Create Translation Files

Create `frontend/lib/l10n/app_en.arb` (English):
```json
{
  "@@locale": "en",
  "appTitle": "MarketLens",
  "welcomeBack": "Welcome back! 👋",
  "scanProduct": "Scan a Product",
  "pointCamera": "Point your camera at any product",
  "history": "History",
  "favorites": "Favorites",
  "compareProducts": "Compare Products",
  "priceAlerts": "Price Alerts",
  "productDetails": "Product Details",
  "buyNow": "Buy Now",
  "addToComparison": "Compare",
  "addToFavorites": "Favorite",
  "setPriceAlert": "Price Alert",
  "share": "Share",
  "specifications": "Specifications",
  "description": "Description",
  "priceComparison": "Price Comparison",
  "lowestPrice": "Lowest Price",
  "availableCoupons": "Available Coupons",
  "alternatives": "Alternatives",
  "bestDeal": "Best Deal",
  "filterSpecs": "Filter Specifications",
  "saveComparison": "Save Comparison",
  "login": "Login",
  "register": "Register",
  "email": "Email",
  "password": "Password",
  "confirmPassword": "Confirm Password",
  "fullName": "Full Name",
  "signIn": "Sign In",
  "signUp": "Sign Up",
  "signInWithGoogle": "Sign in with Google",
  "signInWithFacebook": "Sign in with Facebook",
  "profile": "Profile",
  "settings": "Settings",
  "logout": "Logout",
  "language": "Language",
  "notifications": "Notifications",
  "currency": "Currency",
  "about": "About"
}
```

Create `frontend/lib/l10n/app_ar.arb` (Arabic):
```json
{
  "@@locale": "ar",
  "appTitle": "ماركت لينس",
  "welcomeBack": "مرحباً بعودتك! 👋",
  "scanProduct": "مسح منتج",
  "pointCamera": "وجّه الكاميرا نحو أي منتج",
  "history": "السجل",
  "favorites": "المفضلة",
  "compareProducts": "مقارنة المنتجات",
  "priceAlerts": "تنبيهات الأسعار",
  "productDetails": "تفاصيل المنتج",
  "buyNow": "اشترِ الآن",
  "addToComparison": "مقارنة",
  "addToFavorites": "مفضلة",
  "setPriceAlert": "تنبيه السعر",
  "share": "مشاركة",
  "specifications": "المواصفات",
  "description": "الوصف",
  "priceComparison": "مقارنة الأسعار",
  "lowestPrice": "أقل سعر",
  "availableCoupons": "كوبونات متاحة",
  "alternatives": "بدائل",
  "bestDeal": "أفضل صفقة",
  "filterSpecs": "تصفية المواصفات",
  "saveComparison": "حفظ المقارنة",
  "login": "تسجيل الدخول",
  "register": "تسجيل جديد",
  "email": "البريد الإلكتروني",
  "password": "كلمة المرور",
  "confirmPassword": "تأكيد كلمة المرور",
  "fullName": "الاسم الكامل",
  "signIn": "دخول",
  "signUp": "تسجيل",
  "signInWithGoogle": "تسجيل الدخول بجوجل",
  "signInWithFacebook": "تسجيل الدخول بفيسبوك",
  "profile": "الملف الشخصي",
  "settings": "الإعدادات",
  "logout": "خروج",
  "language": "اللغة",
  "notifications": "الإشعارات",
  "currency": "العملة",
  "about": "حول"
}
```

### 4. Update Main App

Update `main.dart`:
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:marketlens/l10n/app_localizations.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MarketLens',
      debugShowCheckedModeBanner: false,
      
      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ar', ''), // Arabic
      ],
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Routes
      initialRoute: '/',
      routes: {
        // ... existing routes
      },
    );
  }
}
```

### 5. Use Translations in Widgets

Example for `home_screen.dart`:
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// OLD
Text('Welcome back! 👋')

// NEW
Text(AppLocalizations.of(context)!.welcomeBack)
```

### 6. Add Language Switcher

Create `frontend/lib/providers/locale_provider.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }
  
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('locale') ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
```

Update `main.dart`:
```dart
import 'package:provider/provider.dart';
import 'package:marketlens/providers/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  await MobileAds.instance.initialize();
  
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  
  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          locale: localeProvider.locale,
          // ... rest of config
        );
      },
    );
  }
}
```

Add to `profile_screen.dart`:
```dart
ListTile(
  leading: const Icon(Icons.language),
  title: Text(AppLocalizations.of(context)!.language),
  subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                  .setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                  .setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  },
),
```

---

## Testing Checklist

### Phase 4B:
- [ ] Firebase initialized without errors
- [ ] Analytics events logged
- [ ] Crashlytics captures errors
- [ ] Push notifications received
- [ ] Remote Config values fetched
- [ ] Banner ads displayed
- [ ] Native ads loaded
- [ ] Interstitial ads shown between screens
- [ ] Subscription purchase flow works
- [ ] Google Sign-In successful
- [ ] Facebook Sign-In successful

### Phase 4C:
- [ ] English translations displayed
- [ ] Arabic translations displayed
- [ ] Language switcher works
- [ ] RTL layout in Arabic
- [ ] All screens translated
- [ ] Locale persisted after restart

---

## Environment Variables

Add to `backend/.env`:
```env
# Admitad
ADMITAD_CLIENT_ID=your_admitad_client_id
ADMITAD_CLIENT_SECRET=your_admitad_client_secret

# Google Cloud Vision
GOOGLE_CLOUD_PROJECT_ID=your_project_id
GOOGLE_APPLICATION_CREDENTIALS=./config/google-cloud-key.json

# MongoDB
MONGODB_URI=mongodb://localhost:27017/marketlens

# JWT
JWT_SECRET=your_very_secure_jwt_secret_here
```

---

## Final Steps

1. Run `flutter pub get`
2. Run `flutter gen-l10n` (generates localization files)
3. Test on Android 7+ device
4. Test on Android 15 device
5. Test in light and dark modes
6. Test in English and Arabic
7. Build release APK: `flutter build apk --release`
8. Upload to Google Play Console (Internal Testing)

---

**Phase 4B Estimated Time:** 1-2 days  
**Phase 4C Estimated Time:** 1 day  
**Total to 100%:** 2-3 days

**Status:** Ready for implementation  
**Dependencies:** All documented above
