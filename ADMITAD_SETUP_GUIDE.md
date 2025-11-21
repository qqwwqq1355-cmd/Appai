# 🚀 دليل إعداد Admitad API - Admitad Integration Guide

## 📋 نظرة عامة / Overview

تم إضافة تكامل Admitad API للحصول على منتجات من متاجر متعددة:
- ✅ Shein
- ✅ Temu  
- ✅ AliExpress
- ✅ Amazon (عبر Admitad)
- ✅ ومئات المتاجر الأخرى

---

## 🔑 الخطوة 1: التسجيل في Admitad

### 1. إنشاء حساب Publisher

**رابط التسجيل:**
```
https://publishers.admitad.com
```

**الخطوات:**
1. اذهب إلى https://publishers.admitad.com
2. انقر على "Sign Up" أو "Register"
3. اختر "Publisher" (ناشر)
4. املأ البيانات المطلوبة:
   - الاسم
   - البريد الإلكتروني
   - الموقع/التطبيق (يمكنك وضع "Mobile App - MarketLens")
5. أكمل عملية التسجيل

### 2. اختيار المتاجر (Programs)

بعد التسجيل:
1. اذهب إلى "Programs" أو "الحملات"
2. ابحث عن المتاجر التي تريدها:
   - **Shein** - ملابس وأزياء
   - **Temu** - منتجات متنوعة
   - **AliExpress** - إلكترونيات ومنتجات صينية
   - **Amazon** - كل شيء
   - وغيرها...
3. اضغط "Join" أو "الانضمام" لكل متجر
4. انتظر الموافقة (عادة فورية أو خلال 24 ساعة)

---

## 🔐 الخطوة 2: الحصول على API Credentials

### الوصول إلى API Settings

1. سجل دخول إلى حسابك في Admitad
2. اذهب إلى **Settings** > **API**
3. أنشئ OAuth2 Client:
   - **Client Name:** MarketLens Backend
   - **Redirect URI:** `http://localhost:3000/api/admitad/callback`
   - **Scopes:** اختر `public_data`

### ستحصل على:
```
Client ID: xxxxxxxxxxxxxxxx
Client Secret: yyyyyyyyyyyyyyyy
```

**⚠️ احتفظ بهذه البيانات بشكل آمن!**

---

## ⚙️ الخطوة 3: إضافة المفاتيح إلى المشروع

### تعديل ملف `.env`

1. افتح ملف `.env` في مجلد `backend`
2. أضف/عدّل هذه الأسطر:

```env
# Admitad API Configuration
ADMITAD_CLIENT_ID=your_actual_client_id_here
ADMITAD_CLIENT_SECRET=your_actual_client_secret_here
ADMITAD_REDIRECT_URI=http://localhost:3000/api/admitad/callback
```

**مثال:**
```env
ADMITAD_CLIENT_ID=abc123def456ghi789
ADMITAD_CLIENT_SECRET=xyz987uvw654rst321
ADMITAD_REDIRECT_URI=http://localhost:3000/api/admitad/callback
```

### احفظ الملف وأعد تشغيل السيرفر:
```bash
cd backend
npm start
```

---

## 🧪 الخطوة 4: اختبار التكامل

### 1. تحقق من الإعدادات

```bash
curl http://localhost:3000/api/admitad/status
```

يجب أن تحصل على:
```json
{
  "configured": true,
  "message": "Admitad API is configured and ready"
}
```

### 2. جلب قائمة المتاجر

```bash
curl http://localhost:3000/api/admitad/stores
```

### 3. البحث عن منتجات

```bash
curl "http://localhost:3000/api/admitad/search?q=headphones"
```

### 4. الحصول على توصيات

```bash
curl "http://localhost:3000/api/admitad/recommendations?product=iPhone&limit=5"
```

---

## 📚 API Endpoints المتاحة

### GET `/api/admitad/status`
التحقق من إعدادات API
```json
Response: { "configured": true/false, "message": "..." }
```

### GET `/api/admitad/stores`
الحصول على قائمة المتاجر المتاحة
```json
Response: { "count": 100, "stores": [...] }
```

### GET `/api/admitad/search?q=product&limit=20`
البحث عن منتجات
- **q**: كلمة البحث (مطلوب)
- **limit**: عدد النتائج (افتراضي: 20)
- **offset**: للصفحات التالية (افتراضي: 0)

```json
Response: {
  "query": "headphones",
  "count": 20,
  "products": [
    {
      "name": "Sony WH-1000XM5",
      "price": 399.99,
      "currency": "USD",
      "imageUrl": "...",
      "url": "...",
      "store": "Amazon",
      ...
    }
  ]
}
```

### GET `/api/admitad/category/:categoryId`
الحصول على منتجات حسب الفئة

### POST `/api/admitad/affiliate-link`
توليد رابط أفلييت (يحتاج مصادقة)
```json
Request: {
  "url": "https://amazon.com/product/...",
  "campaignId": 12345
}
Response: {
  "originalUrl": "...",
  "affiliateUrl": "..."
}
```

### GET `/api/admitad/recommendations?product=name&limit=5`
الحصول على توصيات منتجات مشابهة

---

## 💡 ملاحظات مهمة

### 🎯 المميزات
- ✅ الوصول إلى مئات المتاجر من API واحد
- ✅ توليد روابط أفلييت تلقائياً
- ✅ عمولات على المبيعات
- ✅ بيانات محدثة باستمرار

### ⚠️ القيود
- معدل الطلبات: حسب خطة Admitad الخاصة بك
- بعض المتاجر تحتاج موافقة قبل الانضمام
- Admitad لا يدعم البحث بالباركود مباشرة (نستخدم اسم المنتج)

### 🔄 سير العمل الموصى به
1. المستخدم يمسح منتج بالكاميرا
2. نستخرج اسم المنتج من الباركود (من قاعدة البيانات)
3. نبحث في Admitad API باسم المنتج
4. نعرض النتائج مع الأسعار
5. عند النقر "Buy" نولد رابط أفلييت

---

## 🆘 حل المشاكل

### خطأ: "Admitad API not configured"
**الحل:**
- تأكد من إضافة `ADMITAD_CLIENT_ID` و `ADMITAD_CLIENT_SECRET` في `.env`
- أعد تشغيل السيرفر

### خطأ: "Failed to authenticate"
**الحل:**
- تحقق من صحة Client ID و Client Secret
- تأكد من أن حسابك نشط في Admitad

### لا توجد نتائج بحث
**الأسباب المحتملة:**
- الكلمة المفتاحية غير موجودة
- لم تنضم لبرامج كافية في Admitad
- انتظر موافقة المتاجر على طلب الانضمام

---

## 📖 موارد إضافية

### روابط مفيدة
- **Admitad Dashboard:** https://publishers.admitad.com
- **API Documentation:** https://developers.admitad.com/en/
- **Help Center:** https://help.admitad.com/hc/en-us

### للدعم
- **Admitad Support:** support@admitad.com
- **API Questions:** api@admitad.com

---

## ✅ Checklist سريع

قبل البدء، تأكد من:
- [ ] حساب Admitad Publisher مفعّل
- [ ] انضممت لـ 5+ برامج على الأقل (Shein, Temu, AliExpress, etc.)
- [ ] حصلت على Client ID & Client Secret
- [ ] أضفت المفاتيح في `.env`
- [ ] ثبّت المكتبات: `npm install`
- [ ] أعدت تشغيل السيرفر
- [ ] اختبرت `/api/admitad/status`

---

**تم التكامل بنجاح! 🎉**

الآن يمكنك البحث عن منتجات من مئات المتاجر وكسب عمولات على المبيعات!
