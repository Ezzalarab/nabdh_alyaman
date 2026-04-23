# دليل إعداد البيئة التطويرية (Mac M2 Setup)

بالنسبة لجهازك **MacBook M2 Air**، فأنت تمتلك جهازاً قوياً جداً لمعمارية ARM. سنستخدم أدوات حديثة وخفيفة تناسب NestJS و PostgreSQL.

---

## 1. الأدوات الأساسية (The Stack)

### أ. إدارة الحزم (Homebrew)
إذا لم يكن مثبتاً:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### ب. بيئة Node.js v20 LTS (عبر nvm)
```bash
brew install nvm

# إضافة nvm لملف الـ shell:
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"' >> ~/.zshrc
source ~/.zshrc

# تثبيت Node.js v20 (LTS المعتمد في هذا المشروع)
nvm install 20
nvm use 20
nvm alias default 20

# التحقق
node --version  # → v20.x.x
npm --version   # → 10.x.x
```

### ج. قاعدة البيانات (PostgreSQL + PostGIS)
```bash
# تثبيت PostgreSQL 16
brew install postgresql@16

# إضافة PostgreSQL للـ PATH
echo 'export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# تثبيت PostGIS (الإضافة الجغرافية)
brew install postgis

# تشغيل الخدمة
brew services start postgresql@16

# إنشاء قاعدة بيانات المشروع
createdb nabdh_dev

# تفعيل PostGIS على قاعدة البيانات
psql nabdh_dev -c "CREATE EXTENSION IF NOT EXISTS postgis;"

# التحقق
psql nabdh_dev -c "SELECT PostGIS_Version();"
```

---

## 2. هيكل مشروع الباكإند (NestJS)

```
nabdh-backend/
  src/
    auth/
    donors/
    donor-search/
    centers/
    locations/
    blood-requests/
    notifications/
    files/
    app-config/
    prisma/
  prisma/
    schema.prisma       # مخطط قاعدة البيانات (راجع database_schema_spec.md)
    migrations/         # ملفات الـ migrations (تُولَّد تلقائياً)
    seed/
      seed.ts           # سكربت استيراد شجرة المواقع
  uploads/              # (خارج المشروع في الإنتاج: /var/www/nabdh-uploads/)
  .env                  # راجع env_variables.md للقائمة الكاملة
  .env.example          # نسخة من .env بدون القيم الحساسة
```

---

## 3. تشغيل المشروع محلياً

```bash
# 1. تحميل المكتبات
npm install

# 2. إنشاء ملف .env من المثال
cp .env.example .env
# ثم عدّل القيم في .env (راجع env_variables.md)

# 3. إنشاء الجداول في قاعدة البيانات المحلية
npx prisma migrate dev --name init

# 4. تنفيذ استعلامات PostGIS اليدوية (مرة واحدة فقط)
psql nabdh_dev -c "ALTER TABLE \"DonorProfile\" ADD COLUMN IF NOT EXISTS coords geography(Point, 4326);"
psql nabdh_dev -c "CREATE INDEX IF NOT EXISTS idx_donor_coords ON \"DonorProfile\" USING GIST (coords);"

# 5. استيراد شجرة المواقع (seed)
npx ts-node prisma/seed/seed.ts

# 6. تشغيل السيرفر مع التحديث التلقائي
npm run start:dev
# السيرفر يعمل على: http://localhost:3000
```

---

## 4. أدوات إدارة قاعدة البيانات (GUI Tools)

| الأداة | الوصف | التوصية |
|---|---|---|
| **Prisma Studio** | مدمج مع المشروع — `npx prisma studio` | ✅ الأسهل والأسرع |
| **TablePlus** | تطبيق Mac Native سريع وجميل | ✅ مُوصى به |
| **pgAdmin 4** | البديل الرسمي لـ phpMyAdmin | ⚠️ أثقل من TablePlus |

---

## 5. أوامر مفيدة للتطوير

```bash
# إنشاء وحدة NestJS جديدة
nest generate module blood-requests
nest generate controller blood-requests
nest generate service blood-requests

# إنشاء migration جديدة بعد تعديل schema.prisma
npx prisma migrate dev --name "add_new_field"

# تطبيق migrations على بيئة الإنتاج (لا تستخدم migrate dev في الإنتاج)
npx prisma migrate deploy

# فتح Prisma Studio
npx prisma studio

# الاطلاع على حالة الـ migrations
npx prisma migrate status
```

---

> [!TIP]
> جميع هذه الأدوات تعمل بشكل أصلي (Native) على معالج M2، مما يوفر سرعة خيالية واستهلاكاً منخفضاً للبطارية. لا تحتاج لـ Docker أو XAMPP.
