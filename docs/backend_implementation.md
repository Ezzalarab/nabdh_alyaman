# الدليل التقني التفصيلي لتنفيذ الباكإند (NestJS + Prisma + PostgreSQL)

هذا المستند هو المرجع الشامل لكافة الجوانب التقنية لتطوير الباكإند، صُمم ليكون دليلاً خطوة بخطوة يمنع أي غموض أو خطأ استراتيجي.

---

## 1. مرحلة التأسيس للمشروع (Project Initialization)

### أ. إنشاء المشروع
يتم البدء باستخدام NestJS CLI لضمان الهيكلية القياسية:
```bash
# تثبيت الـ CLI عالمياً
npm i -g @nestjs/cli

# إنشاء مشروع جديد
nest new nabdh-backend
```

### ب. تثبيت وإعداد Prisma
نستخدم Prisma كـ ORM للتعامل مع PostgreSQL:
```bash
# تثبيت التبعات
npm install prisma --save-dev
npm install @prisma/client

# تهيئة Prisma
npx prisma init
```

---

## 2. هندسة الوحدات والمجلدات (Modular Architecture)

> [!TIP]
> **تطبيق مبدأ الثقة الصفرية Zero-Trust**: سيتم بناء حراس Roles Guard لكل مسار (Endpoint). على سبيل المثال، لا يُرسل الباكإند أي بيانات عن المخزون الطبي أو بيانات المستخدمين الخاصة ما لم يكن الـ Token العائد للمستخدم يمتلك صلاحية `CENTER` أو `ADMIN`. عدم الثقة بالـ Client-side Rule هو أساس الحماية.

يعتمد NestJS على نظام الوحدات (Modules). كل ميزة في التطبيق ستكون وحدة مستقلة تحتوي على:
- **Module**: لتعريف التبعات.
- **Controller**: لاستقبال الطلبات (Endpoints).
- **Service**: لكتابة منطق العمل (Business Logic).
- **DTO**: لتعريف شكل البيانات المدخلة والتحقق منها.

### هيكلية المجلدات التفصيلية:
```text
/src
  /auth               # وحدة المصادقة والحماية والتشفير
  /users              # وحدة إدارة المستخدمين المتبرعين
  /donors             # وحدة البحث الجغرافي
  /centers            # وحدة المراكز وإدارة المخزون
  /locations          # وحدة جلب المناطق (الدول، المحافظات، المدن)
  /notifications      # وحدة الربط مع FCM
  /files              # وحدة الـ Proxy لإدارة الملفات
```

---

## 3. حماية البيانات والتشفير (Data Security & Encryption)

### أ. تشفير كلمات المرور
نستخدم مكتبة `argon2` لتشفير كلمات المرور.

### ب. حماية الـ API (Rate Limiting)
نستخدم `ThrottlerModule` لحماية الـ Endpoints من هجمات الإغراق:
```bash
npm i --save @nestjs/throttler
```
يتم تعيين سقف (مثلاً 10 طلبات في الدقيقة لنداءات الاستغاثة) لحماية رصيد الـ SMS والسيرفر.

### ج. تشفير البيانات الحساسة (AES-256-GCM)
لحماية خصوصية المتبرعين، سنقوم بتشفير أرقام الهواتف قبل تخزينها:
```typescript
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

// استخدام مفتاح سري (Secret Key) مخزن في ملف .env
const encrypt = (text: string) => {
  const iv = randomBytes(16);
  // ملاحظة: يُستخدم الفهرس الأعمى (Blind Index) HMAC للبحث وتسجيل الدخول
  // const phoneHash = createHmac('sha256', process.env.HMAC_KEY).update(phone).digest('hex');
  const cipher = createCipheriv('aes-256-cbc', process.env.ENCRYPTION_KEY, iv);
  let encrypted = cipher.update(text);
  encrypted = Buffer.concat([encrypted, cipher.final()]);
  return iv.toString('hex') + ':' + encrypted.toString('hex');
};
```

---

## 4. معايير التوقيت العالمي (Timezone Management)

لضمان دقة السجلات (تبرع، إشعارات، مخزون):
- **قاعدة البيانات**: يتم التخزين دائماً بصيغة **UTC** باستخدام نوع `TIMESTAMPTZ`.
- **الباكإند**: نستخدم مكتبة `Luxon` للتعامل مع التواريخ بمعيار UTC.
- **تطبيق الموبايل**: هو المسؤول عن تحويل الـ UTC إلى التوقيت المحلي للمستخدم (GMT+3 في اليمن).

---

## 5. منطق البحث الجغرافي المتقدم (Geospatial Logic)

بما أن Prisma لا تدعم `Geography` بشكل افتراضي كامل، نستخدم الاستعلامات الخام (Raw Queries):
**ملاحظة هامة جداً**: يجب تنفيذ الفهرس هذا في PostgreSQL مباشرة لضمان السرعة ومنع اختناق السيرفر (CPU Bottleneck):
```sql
CREATE INDEX idx_user_coords ON "DonorProfile" USING GIST (coords);
```

```sql
SELECT id, full_name, 
       ST_Distance(coords, ST_MakePoint(lon, lat)::geography) / 1000 as distance_km
FROM "DonorProfile"
WHERE ST_DWithin(coords, ST_MakePoint(lon, lat)::geography, 10000)
ORDER BY distance_km ASC;
```

---

## 6. استراتيجية النشر (Bare-metal Deployment)

نظراً لمحدودية موارد السيرفر، سنعتمد التنصيب المباشر (No Docker).

### أ. إدارة العمليات (PM2)
استخدام **PM2** لتشغيل سيرفر NestJS وضمان استمراريته:
```bash
npm install pm2 -g
pm2 start dist/main.js --name "nabdh-backend"
```

### ب. سكربت الإعداد الأولي (Setup Script)
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y nodejs npm postgresql postgresql-contrib nginx
sudo npm install pm2 -g
sudo -u postgres psql -c "CREATE EXTENSION IF NOT EXISTS postgis;"

#### تحسين إعدادات PostgreSQL لتقليل استهلاك الرام:
- `shared_buffers`: ضبطه على 128MB.
- `max_connections`: تقليله إلى 30 اتصال.
- **Prisma Connection Pool**: نظراً لأن السيرفر يحتوي على 4 جيجابايت مشتركة مع مشاريع أخرى، سيتم تقليل سقف سحب البيانات لـ Prisma عبر إضافة `?connection_limit=5` لتخفيف الضغط على ذاكرة الخادم.
- `work_mem`: ضبطه على 4MB لكل استعلام.
```

---

## 7. خدمة جلب الملفات الآمنة (Secure File Proxy)
- جلب الملفات عبر الـ UID للتحقق من الأذونات.
- تفعيل **ETag** و **Cache-Control** لتقليل حمل السيرفر.

---

---

## 8. هجرة البيانات (Data Migration)
تم نقل تفاصيل هجرة البيانات إلى مستند مستقل ومعمق: [خطة هجرة البيانات](file:///Users/airm2/Documents/flutter_apps/nabdh_alyaman/docs/data_migration_plan.md).

---

## 9. ملاحظات مستقبلية (Future Considerations)
- **نظام التحقق الطبي**: سيتم لاحقاً إضافة نظام "التحقق من الصلاحية الطبية" (Medical Eligibility) الذي يمنع المتبرع من تفعيل حسابه إذا تبرع خلال أقل من 3 أشهر.
- **توسعة الويب**: تم تأجيل تطوير الويب حالياً للتركيز الكامل على استقرار تطبيق الموبايل لكافة الأدوار.

---

> [!IMPORTANT]
> تم التركيز على كفاءة الأداء وتوفير الموارد لضمان عمل النظام بسلاسة على السيرفرات الضعيفة، مع إمكانية التوسع المستقبلي.
