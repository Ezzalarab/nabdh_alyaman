# متغيرات البيئة المطلوبة (.env Variables Reference)

هذا الملف يوثق جميع متغيرات البيئة اللازمة لتشغيل الباكإند. يجب نسخ هذا الملف إلى `.env.example` في المشروع وإضافة `.env` إلى `.gitignore`.

> [!CAUTION]
> لا ترفع ملف `.env` الحقيقي إلى GitHub أبداً. استخدم `.env.example` بدون القيم الحساسة.

---

## ملف `.env.example` الكامل

```env
# ====================================================
# قاعدة البيانات (PostgreSQL)
# ====================================================
DATABASE_URL="postgresql://USER:PASSWORD@localhost:5432/nabdh_dev?connection_limit=5"
# في الإنتاج: استبدل nabdh_dev بـ nabdh_prod
# connection_limit=5 مهم على السيرفر الضعيف (4GB RAM مشتركة)

# ====================================================
# المصادقة (JWT)
# ====================================================
JWT_SECRET="your_super_secret_key_minimum_32_characters_long"
# يُولَّد عبر: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

JWT_EXPIRES_IN="7d"
# مدة صلاحية الـ Access Token


# ====================================================
# Firebase Admin SDK (للإشعارات FCM)
# ====================================================
FIREBASE_PROJECT_ID="your-firebase-project-id"
FIREBASE_CLIENT_EMAIL="firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com"
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYOUR_KEY_HERE\n-----END PRIVATE KEY-----\n"
# يُستخرج من Firebase Console → Project Settings → Service Accounts → Generate new private key

# ====================================================
# السيرفر والتطبيق
# ====================================================
PORT=3000
NODE_ENV="development"
# في الإنتاج: NODE_ENV="production"

APP_URL="http://localhost:3000"
# في الإنتاج: https://api.nabdh-yemen.com (أو النطاق الفعلي)

# ====================================================
# تخزين الملفات
# ====================================================
UPLOADS_DIR="/var/www/nabdh-uploads"
# المسار الذي تُحفظ فيه الملفات المرفوعة

MAX_FILE_SIZE_MB=5
# الحد الأقصى لحجم الملف المرفوع (بالميغابايت)

# ====================================================
# حماية الـ API (Rate Limiting)
# ====================================================
THROTTLE_TTL_MS=60000
# نافذة زمنية بالمللي ثانية (60000 = دقيقة واحدة)

THROTTLE_LIMIT=30
# عدد الطلبات المسموح بها في النافذة الزمنية

# ====================================================
# مفتاح الهجرة (Migration Placeholder)
# ====================================================
MIGRATION_PLACEHOLDER_HASH="MIGRATED_ACCOUNT_NEEDS_RESET"
# القيمة التي تُحفظ في passwordHash لحسابات الهجرة من Firebase
# تُستخدم كعلامة لمطالبة المستخدم بإعادة ضبط كلمة المرور
```

---

## كيفية توليد المفاتيح السرية

```bash
# توليد JWT_SECRET (32 byte = 64 hex)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

---

## جدول الملخص السريع

| المتغير | الاستخدام | مطلوب في التطوير؟ | مطلوب في الإنتاج؟ |
|---|---|---|---|
| `DATABASE_URL` | الاتصال بـ PostgreSQL | ✅ نعم | ✅ نعم |
| `JWT_SECRET` | توقيع الـ JWT | ✅ نعم | ✅ نعم |
| `JWT_EXPIRES_IN` | مدة صلاحية التوكن | ✅ نعم | ✅ نعم |
| `FIREBASE_PROJECT_ID` | FCM الإشعارات | ⚠️ للاختبار فقط | ✅ نعم |
| `FIREBASE_CLIENT_EMAIL` | FCM الإشعارات | ⚠️ للاختبار فقط | ✅ نعم |
| `FIREBASE_PRIVATE_KEY` | FCM الإشعارات | ⚠️ للاختبار فقط | ✅ نعم |
| `PORT` | منفذ السيرفر | ✅ نعم | ✅ نعم |
| `NODE_ENV` | بيئة التشغيل | ✅ `development` | ✅ `production` |
| `UPLOADS_DIR` | مجلد الملفات | ✅ `./uploads` | ✅ `/var/www/...` |
| `MIGRATION_PLACEHOLDER_HASH` | هجرة Firebase | ✅ نعم | ✅ نعم |

---

> [!NOTE]
> في بيئة الإنتاج، يُفضَّل تخزين المتغيرات الحساسة (`FIREBASE_PRIVATE_KEY` و `JWT_SECRET`) في Secrets Manager أو كـ Environment Variables مباشرة على السيرفر بدلاً من ملف `.env`.
