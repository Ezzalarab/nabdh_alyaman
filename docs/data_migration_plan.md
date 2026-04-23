# خطة هجرة البيانات التفصيلية (Detailed Data Migration Plan)

هذا المستند هو الدليل الإجرائي والاحترازي لعملية نقل البيانات من Firebase إلى PostgreSQL، لضمان سلامة السجلات وعدم فقدان أي معلومة حيوية.

---

## 1. مرحلة التحضير (Preparation Phase)

### أ. الجرد النهائي للبيانات
- تصدير كافة مجموعات Firebase كملفات JSON من Firebase Console.
- المجموعات المستهدفة للهجرة:

| مجموعة Firebase | الجدول الجديد | الملاحظة |
|---|---|---|
| `donors` | `User` + `DonorProfile` | يُقسَّم إلى جدولين |
| `centers` | `User` + `CenterProfile` + `BloodStock` | يُقسَّم إلى ثلاثة جداول |
| `notifications` | `Notification` | هجرة مباشرة |
| `global_app_data` | `AppConfig` | يُحوَّل إلى key-value pairs |
| `search_logs` | `SearchLog` | هجرة اختيارية (بيانات تاريخية) |
| `users_per_day` | يُتجاهل | سيُحسب ديناميكياً لاحقاً |
| `updating` | `AppConfig` | يُخزن كـ key-value في `AppConfig` |

### ب. بيئة الاختبار (Staging)
- إنشاء قاعدة بيانات PostgreSQL محلية للاختبار.
- تشغيل الهجرة على **10% من البيانات** أولاً والتحقق من صحتها.

---

## 2. جدول تحويل الحقول (Field Mapping)

### أ. مجموعة `donors` → `User` + `DonorProfile`

| حقل Firebase | الجدول الجديد | الحقل الجديد | التحويل المطلوب |
|---|---|---|---|
| `id` | `User` | `id` | استخدام UUID جديد (عدم الاعتماد على Firebase UID) |
| `email` | `User` | `email` | مباشر |
| `phone` | `User` | `phone` (مشفر) + `phoneHash` | تشفير AES-256-GCM + HMAC للبحث |
| `password` | `User` | `passwordHash` | **راجع قسم 3-ج** |
| `token` | `User` | `fcmToken` | مباشر |
| `status` | `User` | `status` | تحويل: `"ACTIVE"` → `Status.ACTIVE` |
| `name` | `DonorProfile` | `fullName` | مباشر |
| `blood_type` | `DonorProfile` | `bloodType` | تحويل: `"A+"` → `"A+"` (بدون تغيير) |
| `gender` | `DonorProfile` | `gender` | تحويل: نص عربي → `Gender.MALE/FEMALE` |
| `brith_date` | `DonorProfile` | `birthDate` | تحويل: String → DateTime (UTC) |
| `image` | `DonorProfile` | `imageUrl` | مباشر (URL Firebase Storage) |
| `is_shown` | `DonorProfile` | `isShown` | تحويل: `"0"/"1"` → `false/true` |
| `is_shown_phone` | `DonorProfile` | `isPhoneShown` | تحويل: `"0"/"1"` → `false/true` |
| `is_gps_on` | `DonorProfile` | `isGpsOn` | تحويل: `"0"/"1"` → `false/true` |
| `state` + `district` + `neighborhood` | `DonorProfile` | `locationId` | بحث في جدول `Location` + تحويل اسم → ID |
| `lat` + `lon` | `DonorProfile` | `coords` (PostGIS) | تحويل: String → Float → Geography Point |
| `created_at` | `User` | `createdAt` | تحويل: Timestamp → DateTime (UTC) |

---

### ب. مجموعة `centers` → `User` + `CenterProfile` + `BloodStock`

| حقل Firebase | الجدول الجديد | الحقل الجديد | التحويل المطلوب |
|---|---|---|---|
| `id` | `User` | `id` | UUID جديد |
| `email` | `User` | `email` | مباشر |
| `phone` | `User` | `phone` + `phoneHash` | تشفير |
| `password` | `User` | `passwordHash` | راجع قسم 3-ج |
| `token` | `User` | `fcmToken` | مباشر |
| `name` | `CenterProfile` | `name` | مباشر |
| `image` | `CenterProfile` | `imageUrl` | مباشر |
| `state` + `district` + `neighborhood` | `CenterProfile` | `locationId` | اسم → ID |
| `lat` + `lon` | `CenterProfile` | `lat` + `lon` | تحويل String → Float |
| `last_update` | `CenterProfile` | `lastUpdate` | تحويل String → DateTime |
| `A+`, `A-`, `B+`... | `BloodStock` | `bloodType` + `quantity` | كل فصيلة → صف مستقل |

---

### ج. مجموعة `global_app_data` → `AppConfig`

| حقل Firebase | key في AppConfig | ملاحظة |
|---|---|---|
| `app_name` | `app_name` | مباشر |
| `about_app` | `about_app` | مباشر |
| `home_header` | `home_header` | مباشر |
| `info_list` | `info_list` | JSON String |
| `home_slides` | `home_slides` | JSON Array String |
| `events_cards_data` | `events_cards_data` | JSON String |
| `report_link` | `report_link` | مباشر |

---

## 3. ميكانيكية الهجرة (Migration Pipeline)

### الخطوة 1: استخراج وتنظيف البيانات
سكربت `migrate.ts` بلغة TypeScript:

```typescript
// 1. قراءة ملفات JSON
const donors = JSON.parse(fs.readFileSync('firebase_donors.json', 'utf-8'));

// 2. تحويل "0"/"1" إلى Boolean
const isShown = donor.is_shown === '1';

// 3. تحويل فصيلة الدم (تنظيف المسافات)
const bloodType = donor.blood_type?.trim().toUpperCase();

// 4. توحيد أسماء المواقع (مثال)
const locationId = await resolveLocation(donor.state, donor.district, donor.neighborhood);
```

### الخطوة 2: توحيد المواقع الجغرافية
```typescript
async function resolveLocation(state: string, district: string, neighborhood: string) {
  // البحث بالاسم مع مرونة في التهجئة
  const location = await prisma.location.findFirst({
    where: {
      nameAr: { contains: normalizeArabic(state) },
      level: 'STATE',
    }
  });
  return location?.id ?? DEFAULT_LOCATION_ID; // معرف "غير محدد" احتياطي
}
```

### الخطوة 3: استراتيجية كلمات المرور (Password Migration Strategy)

> [!IMPORTANT]
> **المشكلة**: كلمات مرور Firebase مشفرة بطريقة Firebase الداخلية ولا يمكن فك تشفيرها.
>
> **الحل المعتمد — إعادة الضبط الإجبارية (Force Reset)**:
> 1. عند الهجرة: يُنشأ كل حساب بـ `passwordHash = MIGRATION_PLACEHOLDER`.
> 2. عند أول محاولة دخول بعد الهجرة: الباكإند يكتشف الـ Placeholder ويُطلب من المستخدم وضع كلمة مرور جديدة.
> 3. بديل أبسط: إرسال إشعار لجميع المستخدمين بأن عليهم "نسيت كلمة المرور" لإعادة الضبط مرة واحدة.

### الخطوة 4: الإحداثيات الجغرافية
```typescript
// إذا كان لديه إحداثيات GPS حقيقية:
if (donor.lat && donor.lon) {
  await prisma.$executeRaw`
    UPDATE "DonorProfile"
    SET coords = ST_MakePoint(${parseFloat(donor.lon)}, ${parseFloat(donor.lat)})::geography
    WHERE "userId" = ${userId}
  `;
} else {
  // استخدام إحداثيات مركز المديرية من ملف seed_locations.md
  const centerCoords = DISTRICT_CENTERS[locationId];
  if (centerCoords) {
    await prisma.$executeRaw`
      UPDATE "DonorProfile"
      SET coords = ST_MakePoint(${centerCoords.lon}, ${centerCoords.lat})::geography
      WHERE "userId" = ${userId}
    `;
  }
}
```

> **مصدر إحداثيات مراكز المديريات**: موثق في ملف `seed_locations.md`.

### الخطوة 5: تشفير أرقام الهواتف
```typescript
// تنسيق الرقم أولاً (إضافة +967 إذا لم يكن موجوداً)
const formatted = formatYemeniPhone(donor.phone); // مثلاً: 0777... → +967777...

// تشفير
const phone = encryptPhone(formatted);
const phoneHash = hashPhone(formatted);
```

### الخطوة 6: فحص التكرار (De-duplication)
- **نفس رقم الهاتف**: الاحتفاظ بالأحدث (آخر `created_at`) وتسجيل القديم في `failed_migration.log`.
- **نفس البريد الإلكتروني**: نفس المعالجة.

### الخطوة 7: الحقن الجماعي (Batch Insert)
```typescript
// 500 سجل في كل دفعة لتجنب نفاد الذاكرة
const BATCH_SIZE = 500;
for (let i = 0; i < users.length; i += BATCH_SIZE) {
  const batch = users.slice(i, i + BATCH_SIZE);
  await prisma.user.createMany({ data: batch, skipDuplicates: true });
}
```

---

## 4. قائمة الاحتياطات والضمانات

- [ ] **نسخة احتياطية**: أخذ Export كامل من Firebase قبل البدء.
- [ ] **وضع الصيانة**: إيقاف التسجيل في التطبيق القديم أثناء ساعة الهجرة.
- [ ] **الهجرة التجريبية**: تشغيل السكربت على 10% من البيانات والتحقق يدوياً.
- [ ] **سجل الأخطاء**: السكربت يحفظ الفشل في `failed_migration.log`.
- [ ] **المطابقة اليدوية**: اختيار 50 مستخدم عشوائياً والتأكد من صحة بياناتهم.
- [ ] **إشعار المستخدمين**: إرسال إشعار بضرورة إعادة ضبط كلمة المرور.

---

## 5. خطة التراجع (Rollback Plan)

في حال حدوث خطأ كارثي:
1. مسح جداول PostgreSQL: `TRUNCATE "User" CASCADE;`
2. إعادة توجيه التطبيق للنسخة القديمة (Firebase) — يكفي تغيير Base URL في Config التطبيق.
3. إصلاح سكربت الهجرة وإعادة المحاولة.

---

> [!CAUTION]
> لا تُنفِّذ الهجرة الفعلية إلا بعد نجاح الهجرة التجريبية بنسبة 100% دون أي خطأ في سجلات SQL.
