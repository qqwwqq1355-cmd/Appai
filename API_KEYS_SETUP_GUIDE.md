# 🔑 API Keys & Secrets Setup Guide

## Complete Guide for Adding All API Keys and Secrets

This document provides **exact locations and formats** for all API keys and secrets needed to run the MarketLens application.

---

## 📋 Overview

You need to add keys for:
1. **Backend Services** (5 keys in .env file)
2. **Firebase** (1 configuration file)
3. **AdMob** (4 ad unit IDs)
4. **Facebook** (2 IDs)

**Total Time:** ~30 minutes

---

## 1️⃣ Backend API Keys (.env file)

### Location: `backend/.env`

Create or update this file with the following:

```env
# ============================================
# Server Configuration
# ============================================
PORT=3000
NODE_ENV=production

# ============================================
# Database
# ============================================
# Option 1: Local MongoDB
MONGODB_URI=mongodb://localhost:27017/marketlens

# Option 2: MongoDB Atlas (Recommended)
# Get from: https://cloud.mongodb.com
# Example: MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/marketlens
MONGODB_URI=<YOUR_MONGODB_ATLAS_URI>

# ============================================
# JWT Authentication
# ============================================
# Generate a random 32+ character string
# Example: openssl rand -base64 32
JWT_SECRET=<YOUR_RANDOM_JWT_SECRET_32_CHARS_MINIMUM>

# ============================================
# Admitad API
# ============================================
# Get from: https://publishers.admitad.com
# 1. Register as Publisher
# 2. Go to API Settings
# 3. Create OAuth Client
ADMITAD_CLIENT_ID=<YOUR_ADMITAD_CLIENT_ID>
ADMITAD_CLIENT_SECRET=<YOUR_ADMITAD_CLIENT_SECRET>
ADMITAD_REDIRECT_URI=http://localhost:3000/api/admitad/callback

# ============================================
# Google Cloud Vision
# ============================================
# Get from: https://console.cloud.google.com
# 1. Create/Select Project
# 2. Enable Cloud Vision API
# 3. Create Service Account
# 4. Download JSON key (see section below)
GOOGLE_CLOUD_PROJECT_ID=<YOUR_GCP_PROJECT_ID>
GOOGLE_APPLICATION_CREDENTIALS=./config/google-cloud-key.json

# ============================================
# CORS (for production)
# ============================================
CORS_ORIGIN=https://yourdomain.com
```

### How to Generate JWT_SECRET:

**Option 1 - Using OpenSSL (Linux/Mac):**
```bash
openssl rand -base64 32
```

**Option 2 - Using Node.js:**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

**Option 3 - Online Generator:**
- Visit: https://randomkeygen.com/
- Use "CodeIgniter Encryption Keys" (256-bit)

---

## 2️⃣ Google Cloud Service Account Key

### Location: `backend/config/google-cloud-key.json`

### How to Get:

1. **Go to Google Cloud Console:**
   - https://console.cloud.google.com

2. **Create/Select Project:**
   - Click project dropdown → New Project
   - Name: "MarketLens"
   - Create

3. **Enable Cloud Vision API:**
   - Navigation Menu → APIs & Services → Library
   - Search "Cloud Vision API"
   - Click → Enable

4. **Create Service Account:**
   - Navigation Menu → IAM & Admin → Service Accounts
   - Click "Create Service Account"
   - Name: "marketlens-vision"
   - Role: "Cloud Vision API User"
   - Create

5. **Download JSON Key:**
   - Click on created service account
   - Keys tab → Add Key → Create New Key
   - Type: JSON
   - Download

6. **Place File:**
   ```bash
   mv ~/Downloads/marketlens-vision-xxxxx.json backend/config/google-cloud-key.json
   ```

### File Structure (for reference):
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...",
  "client_email": "marketlens-vision@your-project.iam.gserviceaccount.com",
  "client_id": "...",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

**⚠️ SECURITY:** Never commit this file to git. It's already in .gitignore.

---

## 3️⃣ Firebase Configuration

### Location: `android/app/google-services.json`

### How to Get:

1. **Go to Firebase Console:**
   - https://console.firebase.google.com

2. **Create/Select Project:**
   - Click "Add project"
   - Name: "MarketLens"
   - Enable Google Analytics
   - Create

3. **Add Android App:**
   - Click Android icon
   - Package name: `com.marketlens.app`
   - App nickname: "MarketLens"
   - Register app

4. **Download config file:**
   - Download `google-services.json`
   
5. **Place file:**
   ```bash
   mv ~/Downloads/google-services.json android/app/google-services.json
   ```

### Enable Firebase Services:

**In Firebase Console:**

1. **Cloud Messaging (FCM):**
   - Build → Cloud Messaging
   - Already enabled automatically

2. **Analytics:**
   - Already enabled if you chose it during project creation

3. **Crashlytics:**
   - Build → Crashlytics
   - Click "Enable Crashlytics"

4. **Remote Config:**
   - Build → Remote Config
   - Click "Create configuration"
   - Add parameters:
     ```
     show_banner_ads: true (Boolean)
     show_native_ads: true (Boolean)
     show_interstitial_ads: true (Boolean)
     native_ad_frequency: 10 (Number)
     interstitial_frequency_minutes: 5 (Number)
     ```

**⚠️ SECURITY:** This file is safe to commit (no secrets), but contains project identifiers.

---

## 4️⃣ AdMob Ad Unit IDs

### Location: `frontend/lib/config/ad_config.dart`

### How to Get:

1. **Go to AdMob Console:**
   - https://admob.google.com

2. **Create Account/Sign In:**
   - Link to Google account

3. **Add App:**
   - Apps → Add App
   - Platform: Android
   - App name: "MarketLens"
   - Add

4. **Create Ad Units:**

   **Banner Ad:**
   - Ad units → Add ad unit
   - Format: Banner
   - Name: "Home Banner"
   - Create → Copy Ad unit ID

   **Native Ad:**
   - Ad units → Add ad unit
   - Format: Native
   - Name: "Product List Native"
   - Create → Copy Ad unit ID

   **Interstitial Ad:**
   - Ad units → Add ad unit
   - Format: Interstitial
   - Name: "Navigation Interstitial"
   - Create → Copy Ad unit ID

   **Rewarded Ad (Optional):**
   - Ad units → Add ad unit
   - Format: Rewarded
   - Name: "Premium Unlock"
   - Create → Copy Ad unit ID

5. **Get App ID:**
   - App settings → App ID
   - Format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`

### Update ad_config.dart:

```dart
class AdConfig {
  // REPLACE WITH YOUR ACTUAL APP ID
  static const String appId = 'ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY';
  
  // Set to false when using real ads
  static const bool useTestAds = true;  // Change to false in production!
  
  static String get bannerAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/6300978111'; // Test ID (keep)
    }
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/BBBBBBBBBB';  // YOUR BANNER ID
  }
  
  static String get nativeAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/2247696110'; // Test ID (keep)
    }
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN';  // YOUR NATIVE ID
  }
  
  static String get interstitialAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/1033173712'; // Test ID (keep)
    }
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/IIIIIIIIII';  // YOUR INTERSTITIAL ID
  }
  
  static String get rewardedAdUnitId {
    if (useTestAds) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test ID (keep)
    }
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/RRRRRRRRRR';  // YOUR REWARDED ID
  }
}
```

### Add App ID to AndroidManifest.xml:

**Location:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application>
        <!-- ... other entries ... -->
        
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

**⚠️ TESTING:** Always test with `useTestAds = true` first to avoid policy violations!

---

## 5️⃣ Facebook App Configuration

### Location: `android/app/src/main/res/values/strings.xml`

### How to Get:

1. **Go to Facebook Developers:**
   - https://developers.facebook.com

2. **Create App:**
   - My Apps → Create App
   - Use case: "Other"
   - App type: "Consumer"
   - App name: "MarketLens"
   - Create

3. **Add Facebook Login:**
   - Dashboard → Add Product
   - Find "Facebook Login" → Set Up

4. **Get App ID and Client Token:**
   - Settings → Basic
   - Copy "App ID"
   - Copy "Client Token" (under Advanced)

5. **Configure Android Platform:**
   - Settings → Basic → Add Platform
   - Select Android
   - Package name: `com.marketlens.app`
   - Class name: `com.marketlens.app.MainActivity`
   - Generate Key Hash:
     ```bash
     keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
     ```
   - Password: `android` (default debug keystore)
   - Paste hash → Save

### Create/Update strings.xml:

**Location:** `android/app/src/main/res/values/strings.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">MarketLens</string>
    
    <!-- Facebook Configuration -->
    <string name="facebook_app_id">YOUR_FACEBOOK_APP_ID</string>
    <string name="fb_login_protocol_scheme">fbYOUR_FACEBOOK_APP_ID</string>
    <string name="facebook_client_token">YOUR_FACEBOOK_CLIENT_TOKEN</string>
</resources>
```

**Example (don't use these):**
```xml
<string name="facebook_app_id">123456789012345</string>
<string name="fb_login_protocol_scheme">fb123456789012345</string>
<string name="facebook_client_token">abc123def456ghi789</string>
```

### Update AndroidManifest.xml:

**Location:** `android/app/src/main/AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application>
        <!-- ... other entries ... -->
        
        <!-- Facebook Configuration -->
        <meta-data 
            android:name="com.facebook.sdk.ApplicationId" 
            android:value="@string/facebook_app_id"/>
        
        <meta-data 
            android:name="com.facebook.sdk.ClientToken" 
            android:value="@string/facebook_client_token"/>
        
        <activity 
            android:name="com.facebook.FacebookActivity"
            android:configChanges="keyboard|keyboardHidden|screenLayout|screenSize|orientation"
            android:label="@string/app_name" />
        
        <activity
            android:name="com.facebook.CustomTabActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="@string/fb_login_protocol_scheme" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

---

## 6️⃣ Google Sign-In Configuration

### Already configured via Firebase!

When you added the Android app to Firebase, Google Sign-In was automatically configured.

**To verify:**
1. Firebase Console → Authentication
2. Sign-in method tab
3. Enable "Google" provider
4. Add support email

**No additional keys needed!** The `google-services.json` file contains everything.

---

## ✅ Verification Checklist

After adding all keys, verify:

### Backend:
```bash
cd backend
npm install
npm start
```

**Expected output:**
```
✅ MongoDB connected successfully
✅ Server running on port 3000
```

**Test endpoints:**
```bash
# Test Admitad status
curl http://localhost:3000/api/admitad/status

# Test Vision status
curl http://localhost:3000/api/vision/status
```

### Frontend:
```bash
cd frontend
flutter pub get
flutter gen-l10n  # Generate translations
flutter run
```

**Expected:**
- App builds successfully
- Firebase initializes (check logs)
- Ads load (test ads if useTestAds = true)
- OAuth buttons work
- Language switcher works

---

## 🚨 Security Best Practices

### ✅ DO:
- Keep `.env` file in `.gitignore`
- Keep `google-cloud-key.json` in `.gitignore`
- Use environment variables for secrets
- Use test ad IDs during development
- Rotate secrets if compromised

### ❌ DON'T:
- Commit `.env` to git
- Commit `google-cloud-key.json` to git
- Share secrets publicly
- Use production ad IDs during testing
- Hardcode secrets in code

---

## 📝 Quick Reference

| Service | File Location | Key Type |
|---------|---------------|----------|
| MongoDB | `backend/.env` | Connection URI |
| JWT | `backend/.env` | Random secret |
| Admitad | `backend/.env` | Client ID & Secret |
| Google Vision | `backend/config/` | JSON file |
| Firebase | `android/app/` | JSON file |
| AdMob | `lib/config/ad_config.dart` | Ad Unit IDs |
| Facebook | `res/values/strings.xml` | App ID & Token |

---

## 🆘 Troubleshooting

### MongoDB Connection Error:
```
Error: connect ECONNREFUSED
```
**Solution:** Check MongoDB is running or use MongoDB Atlas URI.

### Firebase Initialization Error:
```
Error: FirebaseApp not initialized
```
**Solution:** Verify `google-services.json` is in correct location.

### Admitad API Error:
```
401 Unauthorized
```
**Solution:** Check Client ID and Secret are correct.

### AdMob Not Showing Ads:
```
No ad loaded
```
**Solution:** 
1. Verify App ID in AndroidManifest.xml
2. Check `useTestAds = true` for testing
3. Wait 1-2 hours after creating ad units

### Facebook Login Error:
```
Invalid key hash
```
**Solution:** Regenerate key hash and update in Facebook Console.

---

## 📞 Support Resources

- **Firebase:** https://firebase.google.com/support
- **AdMob:** https://support.google.com/admob
- **Admitad:** https://help.admitad.com
- **Facebook:** https://developers.facebook.com/support

---

## ✅ Final Checklist

Before launching:

- [ ] All backend keys in `.env`
- [ ] Google Cloud key JSON placed
- [ ] Firebase `google-services.json` placed
- [ ] AdMob App ID in AndroidManifest
- [ ] AdMob Ad Unit IDs in ad_config.dart
- [ ] Facebook App ID in strings.xml
- [ ] All services tested and working
- [ ] Change `useTestAds = false` for production
- [ ] Verify `.gitignore` protects secrets

---

**Total Setup Time: ~30 minutes**  
**Status: All locations documented ✅**  
**Ready for production deployment! 🚀**
