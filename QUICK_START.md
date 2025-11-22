# ShopLensX - دليل البدء السريع
# ShopLensX - Quick Start Guide

## 📱 معلومات التطبيق / App Information

- **الاسم / Name:** ShopLensX - عدسة التسوق الذكية
- **الحزمة / Package:** com.shoplensx.app
- **الإصدار / Version:** 1.0.0 (Build 3000)
- **الحالة / Status:** ✅ جاهز للبناء والإطلاق / Ready to Build & Release

---

## 🚀 البناء السريع / Quick Build

### 1. بناء APK للتجربة / Build APK for Testing

```bash
cd frontend
flutter pub get
flutter build apk --release
```

**الملف الناتج / Output:**
`frontend/build/app/outputs/flutter-apk/app-release.apk`

**التثبيت على الهاتف / Install on Phone:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### 2. بناء AAB للنشر / Build AAB for Google Play

```bash
cd frontend
flutter build appbundle --release
```

**الملف الناتج / Output:**
`frontend/build/app/outputs/bundle/release/app-release.aab`

---

## 📦 البناء عبر GitHub Actions / Build via GitHub Actions

### الطريقة الآلية / Automated Method

1. Push أي تعديل على الفرع / Push any change to branch
2. اذهب إلى Actions في GitHub / Go to Actions tab on GitHub
3. انتظر انتهاء البناء / Wait for build completion
4. قم بتحميل الملفات من Artifacts / Download files from Artifacts:
   - `shoplensx-debug-apk` - للتجربة / For testing
   - `shoplensx-release-apk` - نسخة نهائية / Final APK
   - `shoplensx-release-aab` - للنشر على Play Store / For Play Store

### تشغيل يدوي / Manual Trigger

1. اذهب إلى Actions / Go to Actions tab
2. اختر "Build Android App"
3. اضغط "Run workflow"
4. حمّل الملفات من Artifacts / Download from Artifacts

---

## 🔐 معلومات التوقيع / Signing Information

### Keystore Details

- **الموقع / Location:** `frontend/android/app/keystore/shoplensx-release.jks`
- **Alias:** shoplensx
- **كلمة المرور / Password:** ShopLensX2025

### ملف التكوين / Configuration File

**الموقع / Location:** `frontend/android/key.properties`

```properties
storePassword=ShopLensX2025
keyPassword=ShopLensX2025
keyAlias=shoplensx
storeFile=app/keystore/shoplensx-release.jks
```

> ⚠️ **هام / Important:** احفظ هذه المعلومات! ستحتاجها لكل تحديث في المستقبل  
> Keep this information safe! You'll need it for all future updates.

---

## 📱 التثبيت على الهاتف / Install on Phone

### الطريقة 1: USB

```bash
# تفعيل USB Debugging على الهاتف / Enable USB Debugging on phone
# توصيل الهاتف بالكمبيوتر / Connect phone to computer

adb devices  # تحقق من الاتصال / Verify connection
adb install frontend/build/app/outputs/flutter-apk/app-release.apk
```

### الطريقة 2: مباشرة / Direct Download

1. انسخ ملف APK إلى الهاتف / Copy APK to phone
2. افتح الملف من مدير الملفات / Open file from file manager
3. اضغط تثبيت / Tap Install
4. قد تحتاج للسماح بتثبيت من مصادر غير معروفة  
   You may need to allow installation from unknown sources

---

## 🎨 تخصيص الأيقونة / Customize Icon

الأيقونة المخصصة متوفرة على الرابط:  
Custom icon available at:

**https://copilot.microsoft.com/shares/wMKtiEUiLXvTQkceU6cHh**

اتبع الدليل الكامل في / Follow complete guide in:  
📄 **ICON_INTEGRATION_GUIDE.md**

### طريقة سريعة / Quick Method

```bash
# Using flutter_launcher_icons package
cd frontend
# Add your icon to: assets/icon/app_icon.png
flutter pub run flutter_launcher_icons
```

---

## 🏪 النشر على Google Play / Publish to Google Play

### خطوات النشر / Publishing Steps

1. **بناء AAB / Build AAB:**
```bash
cd frontend
flutter build appbundle --release
```

2. **الذهاب إلى Play Console:**
   - https://play.google.com/console
   - إنشاء تطبيق جديد / Create new app
   - اسم التطبيق: ShopLensX - عدسة التسوق الذكية

3. **رفع AAB:**
   - Production → Create Release
   - Upload `app-release.aab`
   - إضافة ملاحظات الإصدار / Add release notes
   - مراجعة والنشر / Review and publish

### المتطلبات / Requirements

- ✅ سياسة الخصوصية / Privacy Policy URL
- ✅ أيقونة التطبيق 512x512 / App Icon 512x512
- ✅ لقطات الشاشة / Screenshots (at least 2)
- ✅ وصف التطبيق / App Description
- ✅ تصنيف المحتوى / Content Rating

---

## 📖 الأدلة الكاملة / Complete Guides

- **RELEASE_GUIDE.md** - دليل شامل للإصدار والنشر  
  Comprehensive release and deployment guide

- **ICON_INTEGRATION_GUIDE.md** - دليل تكامل الأيقونة المخصصة  
  Custom icon integration guide

- **BUILD_INSTRUCTIONS.md** - تعليمات البناء التفصيلية  
  Detailed build instructions

- **PLATFORM_SETUP_COMPLETE.md** - ملخص إعداد المنصات  
  Platform setup summary

---

## ⚡ أوامر سريعة / Quick Commands

```bash
# تنظيف المشروع / Clean project
cd frontend && flutter clean

# تثبيت المكتبات / Install dependencies
flutter pub get

# بناء Debug APK
flutter build apk --debug

# بناء Release APK
flutter build apk --release

# بناء AAB للنشر / Build AAB for release
flutter build appbundle --release

# التثبيت على الجهاز / Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# إزالة التطبيق / Uninstall app
adb uninstall com.shoplensx.app
```

---

## 🔍 التحقق من التوقيع / Verify Signing

```bash
cd frontend/build/app/outputs/flutter-apk

# التحقق من التوقيع / Verify signature
jarsigner -verify -verbose -certs app-release.apk

# عرض تفاصيل الشهادة / Show certificate details
keytool -printcert -jarfile app-release.apk
```

---

## 🐛 حل المشاكل / Troubleshooting

### المشكلة: فشل البناء / Build Failed

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

### المشكلة: خطأ في التوقيع / Signing Error

```bash
# تحقق من وجود key.properties / Verify key.properties exists
cat android/key.properties

# تحقق من وجود الkeystore / Verify keystore exists
ls -la android/app/keystore/shoplensx-release.jks
```

### المشكلة: لا يمكن التثبيت / Cannot Install

```bash
# إزالة النسخة القديمة / Uninstall old version
adb uninstall com.shoplensx.app

# إعادة التثبيت / Reinstall
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 📊 ملخص الملفات / Files Summary

### الملفات المهمة / Important Files

```
Appai/
├── RELEASE_GUIDE.md              # دليل الإصدار الشامل
├── ICON_INTEGRATION_GUIDE.md     # دليل الأيقونة
├── QUICK_START.md                # هذا الملف
│
├── frontend/
│   ├── pubspec.yaml              # معلومات التطبيق
│   │
│   ├── android/
│   │   ├── key.properties        # بيانات التوقيع
│   │   └── app/
│   │       ├── build.gradle      # إعدادات البناء
│   │       └── keystore/
│   │           └── shoplensx-release.jks  # ملف التوقيع
│   │
│   └── build/app/outputs/
│       ├── flutter-apk/
│       │   └── app-release.apk   # ملف APK النهائي
│       └── bundle/release/
│           └── app-release.aab   # ملف AAB للنشر
│
└── .github/workflows/
    └── build-android.yml         # سير العمل الآلي
```

---

## ✨ الحالة الحالية / Current Status

- ✅ التطبيق مُعاد تسميته إلى ShopLensX  
  App rebranded to ShopLensX

- ✅ الحزمة محدثة إلى com.shoplensx.app  
  Package updated to com.shoplensx.app

- ✅ الإصدار محدث إلى 1.0.0 (3000)  
  Version updated to 1.0.0 (3000)

- ✅ Keystore مُنشأ ومُكوّن  
  Keystore generated and configured

- ✅ GitHub Actions مُعدّ للبناء الآلي  
  GitHub Actions configured for automated builds

- ✅ التوثيق الشامل متوفر  
  Comprehensive documentation available

- ⏳ جاهز للبناء والإطلاق!  
  Ready to build and release!

---

## 📞 الدعم / Support

للمزيد من المعلومات، راجع:  
For more information, see:

- **RELEASE_GUIDE.md** - للتفاصيل الكاملة / For complete details
- **GitHub Actions** - للبناء الآلي / For automated builds
- **Issues** - للإبلاغ عن المشاكل / To report problems

---

**Last Updated:** November 22, 2025  
**App Version:** 1.0.0 (Build 3000)  
**Status:** ✅ Ready for Release
