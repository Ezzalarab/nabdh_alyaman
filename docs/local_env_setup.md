# دليل إعداد البيئة التطويرية (Mac M2 Setup)

بالنسبة لجهازك **MacBook M2 Air**، فأنت تمتلك جهازاً قوياً جداً لمعمارية ARM. لا تحتاج لاستخدام XAMPP (الذي عفا عليه الزمن)، بل سنستخدم أدوات حديثة تناسب NestJS و PostgreSQL.

---

## 1. الأدوات الأساسية (The Stack)

### أ. إدارة الحزم (Homebrew)
إذا لم يكن مثبتًا، افتح الـ Terminal وقم بتثبيته:
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### ب. بيئة Node.js (عبر nvm)
من الأفضل استخدام `nvm` للتحكم في إصدارات Node:
`brew install nvm`

### ج. قاعدة البيانات (Native PostgreSQL) - *الخيار الأخف*
بما أنك تفضل حلاً أخف من Docker لتوفير موارد الجهاز والسيرفر:
- قم بتثبيت PostgreSQL مباشرة عبر Homebrew:
  `brew install postgresql@16`
- قم بتفعيل إضافة PostGIS:
  `brew install postgis`
- ابدأ الخدمة:
  `brew services start postgresql@16`

### د. سكربت الإعداد السريع (Setup Script Template)
يمكننا إنشاء ملف `setup.sh` يقوم بالتالي:
1. التأكد من وجود Node.js.
2. تثبيت PostgreSQL و PostGIS.
3. إنشاء قاعدة بيانات المشروع.
4. تثبيت مكتبات `npm`.
5. تشغيل `npx prisma migrate dev`.

---

## 2. كيف تتصفح البيانات (PostgreSQL GUIs)
بما أنك قادم من phpMyAdmin، إليك البدائل الأفضل على الماك:

1.  **Prisma Studio (المدمج)**:
    - الأفضل والأسهل مع NestJS.
    - فقط اكتب `npx prisma studio` في مجلد المشروع، وسيخت لك واجهة ويب جميلة جداً لإدارة الجداول.
2.  **TablePlus (نصيحة الخبراء)**:
    - تطبيق Mac Native سريع جداً وجميل يدعم PostgreSQL.
    - النسخة المجانية كافية جداً لعملك.
3.  **pgAdmin 4**:
    - هو البديل المباشر المصنعي لـ phpMyAdmin، ولكنه أثقل قليلاً من TablePlus.

---

## 3. تشغيل المشروع محلياً
لا تختلف الطريقة عن أي مشروع Node.js:
1. `npm install` لتحميل المكتبات.
2. `npx prisma migrate dev` لإنشاء الجداول في قاعدة بياناتك المحلية.
3. `npm run start:dev` لتشغيل السيرفر مع ميزة التحديث التلقائي عند الحفظ.

---

## 4. هيكلية المجلدات والأدوار (Simplified Structure)
كما طلبتم، سنركز على تطبيق الموبايل لكافة الأدوار:
- `lib/core`: يحتوي على منطق التشفير (Encryption) والتعامل مع التوقيت (UTC conversion).
- `lib/features/donor`: واجهات المتبرع.
- `lib/features/medical_center`: واجهات المركز الطبي.
- `lib/features/admin`: واجهات المشرف.

هذا التقسيم يسهل عملية التوسع لاحقاً (Scalability) دون التأثير على أداء السيرفر.

---

> [!TIP]
> جميع هذه الأدوات تعمل بشكل أصلي (Native) على معالج M2، مما يوفر لك سرعة خيالية واستهلاكاً منخفضاً جداً للبطارية مقارنة بـ XAMPP.
