# الدليل التفصيلي لمخطط قاعدة البيانات (Exhaustive Schema Specification)

هذا المستند يقدم المخطط البرمجي النهائي (Prisma Schema) والعلاقات بين الجداول، مع شرح كل حقل والقيود المفروضة عليه.

---

## 1. تصميم الجداول باستخدام Prisma Syntax

### أ. Enums (التعدادات)
يتم تعريف جميع الـ Enums أولاً لاستخدامها في النماذج:

```prisma
enum Role {
  DONOR
  CENTER
  ADMIN
  SUPER_ADMIN
}

enum Status {
  ACTIVE
  BLOCKED
  PENDING
}

enum Gender {
  MALE
  FEMALE
}

enum LocationLevel {
  COUNTRY    // دولة
  STATE      // محافظة
  DISTRICT   // مديرية
  CITY       // حي / منطقة
}

enum RequestStatus {
  OPEN        // مفتوح — ينتظر متبرعين
  FULFILLED   // اكتمل التبرع
  EXPIRED     // انتهت المدة دون استيفاء
  CANCELLED   // ألغاه صاحب الطلب
}

enum Urgency {
  NORMAL
  HIGH
  CRITICAL
}
```

---

### ب. جدول المستخدمين (User)
المسؤول عن تسجيل الدخول والصلاحيات لجميع الأدوار.

```prisma
model User {
  id              String   @id @default(uuid())
  email           String?  @unique
  phone           String   // رقم الهاتف مشفر (AES-256-GCM)
  phoneHash       String   @unique // فهرس أعمى (HMAC-SHA256) للبحث وتسجيل الدخول
  passwordHash    String
  role            Role     @default(DONOR)
  status          Status   @default(ACTIVE)
  fcmToken        String?  @db.Text
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt

  // العلاقات
  donorProfile    DonorProfile?
  centerProfile   CenterProfile?
  notifications   Notification[]
  searchLogs      SearchLog[]
  bloodRequests   BloodRequest[]
  files           StoredFile[]
}
```

---

### ج. جدول ملف المتبرع (DonorProfile)
يحتوي على البيانات الشخصية والمكانية للمتبرع.

```prisma
model DonorProfile {
  userId       String   @id @map("user_id")
  fullName     String
  bloodType    String   @db.VarChar(5)  // A+, A-, B+, B-, AB+, AB-, O+, O-
  gender       Gender
  birthDate    DateTime?
  locationId   Int

  isShown      Boolean  @default(true)   // هل المتبرع ظاهر في نتائج البحث؟
  isPhoneShown Boolean  @default(true)   // هل رقم هاتفه ظاهر للمراكز؟
  isGpsOn      Boolean  @default(true)   // هل موقعه الجغرافي مفعّل؟
  imageUrl     String?

  // الإحداثيات الجغرافية — يُنشأ عبر SQL مباشرة بعد migrate (راجع قسم PostGIS)
  // coords Geography(Point, 4326)

  user         User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  location     Location      @relation(fields: [locationId], references: [id])
  donations    Donation[]
}
```

> **ملاحظة `coords`**: حقل PostGIS لا يدعمه Prisma مباشرة. بعد تشغيل `prisma migrate`، يُنفَّذ هذا الاستعلام يدوياً مرة واحدة:
> ```sql
> ALTER TABLE "DonorProfile" ADD COLUMN IF NOT EXISTS coords geography(Point, 4326);
> CREATE INDEX idx_donor_coords ON "DonorProfile" USING GIST (coords);
> ```

---

### د. جدول ملف المركز الطبي (CenterProfile)
بيانات المستشفيات وبنوك الدم.

```prisma
model CenterProfile {
  userId     String   @id @map("user_id")
  name       String
  locationId Int
  imageUrl   String?
  lat        Float?
  lon        Float?
  lastUpdate DateTime @default(now())

  user       User          @relation(fields: [userId], references: [id], onDelete: Cascade)
  location   Location      @relation(fields: [locationId], references: [id])
  bloodStock BloodStock[]
  stockLogs  StockTransaction[]
}
```

---

### هـ. جدول المخزون (BloodStock)
كل صف يمثل فصيلة دم واحدة لمركز معين.

```prisma
model BloodStock {
  id        Int      @id @default(autoincrement())
  centerId  String
  bloodType String   @db.VarChar(5)
  quantity  Int      @default(0)
  updatedAt DateTime @updatedAt

  center    CenterProfile @relation(fields: [centerId], references: [userId])

  @@unique([centerId, bloodType]) // كل فصيلة مرة واحدة لكل مركز
}
```

---

### و. سجل المعاملات (StockTransaction)
يُحفظ كل تغيير في المخزون مع السبب — للمراجعة والإحصاء.

```prisma
model StockTransaction {
  id        Int      @id @default(autoincrement())
  centerId  String
  bloodType String   @db.VarChar(5)
  change    Int      // قيمة موجبة (+5) للإضافة، سالبة (-3) للخصم
  reason    String?  // مثال: "تبرع جديد"، "صرف لمريض"
  createdAt DateTime @default(now())
}
```

---

### ز. جدول الإشعارات (Notification)

```prisma
model Notification {
  id        Int      @id @default(autoincrement())
  userId    String
  title     String
  body      String   @db.Text
  isRead    Boolean  @default(false)
  createdAt DateTime @default(now())

  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
}
```

---

### ح. سجل عمليات البحث (SearchLog)

```prisma
model SearchLog {
  id          Int      @id @default(autoincrement())
  userId      String?
  locationId  Int?
  bloodType   String   @db.VarChar(5)
  resultCount Int      @default(0)
  createdAt   DateTime @default(now())

  user        User?     @relation(fields: [userId], references: [id])
  location    Location? @relation(fields: [locationId], references: [id])
}
```

---

### ط. جدول طلبات الاستغاثة (BloodRequest)

```prisma
model BloodRequest {
  id           String        @id @default(uuid())
  requesterId  String
  bloodType    String        @db.VarChar(5)
  locationId   Int
  hospitalName String
  patientName  String?
  unitsNeeded  Int           @default(1)
  urgency      Urgency       @default(NORMAL)
  status       RequestStatus @default(OPEN)
  expiresAt    DateTime?     // وقت انتهاء صلاحية الطلب (اختياري)
  createdAt    DateTime      @default(now())
  updatedAt    DateTime      @updatedAt

  requester    User          @relation(fields: [requesterId], references: [id])
}
```

---

### ي. جدول التبرعات (Donation)
سجل تاريخي لتبرعات كل متبرع.

```prisma
model Donation {
  id        Int      @id @default(autoincrement())
  donorId   String
  centerId  String?  // المركز الذي تم فيه التبرع (اختياري)
  donatedAt DateTime @default(now())
  notes     String?

  donor     DonorProfile @relation(fields: [donorId], references: [userId])
}
```

> **الاستخدام**: يُستخدم هذا الجدول مستقبلاً لنظام "التحقق الطبي" — منع التبرع إذا مرّ أقل من 90 يوماً على آخر تبرع.

---

### ك. هيكلية المواقع (Location)
جدول هرمي يحتوي: اليمن → المحافظات → المديريات → الأحياء.

```prisma
model Location {
  id       Int           @id
  nameAr   String        // الاسم بالعربية
  nameEn   String?       // الاسم بالإنجليزية (اختياري)
  level    LocationLevel
  parentId Int?

  parent   Location?      @relation("LocationHierarchy", fields: [parentId], references: [id])
  children Location[]     @relation("LocationHierarchy")

  donors   DonorProfile[]
  centers  CenterProfile[]
  logs     SearchLog[]
}
```

---

### ل. الملفات المخزنة (StoredFile)

```prisma
model StoredFile {
  id           String   @id @default(uuid())
  originalName String
  storedPath   String   // المسار النسبي داخل مجلد التخزين (uploads/)
  mimeType     String
  size         Int
  isPublic     Boolean  @default(false)
  ownerId      String?
  createdAt    DateTime @default(now())

  user         User?    @relation(fields: [ownerId], references: [id])
}
```

---

### م. بيانات التطبيق العامة (AppConfig)
بديل عن `global_app_data` في Firebase — يُخزن إعدادات التطبيق والـ CMS.

```prisma
model AppConfig {
  key       String @id  // مثال: "about_app"، "home_header"
  value     String @db.Text
  updatedAt DateTime @updatedAt
}
```

> **الاستخدام**: مرن وقابل للتوسع — أي إعداد جديد يُضاف كصف جديد دون تغيير السكيما.

---

## 2. الأمن وتشفير البيانات

| البيانات | الأسلوب | التفاصيل |
|---|---|---|
| كلمات المرور | `Argon2id` | لا تُخزن أبداً كـ Plain text |
| أرقام الهواتف | `AES-256-GCM` | التشفير قبل الحفظ في الـ DB |
| البحث بالهاتف | `HMAC-SHA256` | حقل `phoneHash` للمقارنة فقط |
| JWT | `RS256` أو `HS256` | مدة الصلاحية: 7 أيام، مع Refresh Token |

---

## 3. معايير التوقيت والمواقع

1. **جميع حقول التاريخ**: تُخزن بصيغة **UTC** (`TIMESTAMPTZ` في PostgreSQL).
2. **PostGIS**: نوع `Geography(Point, 4326)` للبحث الجغرافي الدقيق.
3. **التحويل للتوقيت المحلي**: مسؤولية تطبيق الموبايل (GMT+3).

---

## 4. الفهارس (Indexes)

يتم تنفيذ هذه الفهارس يدوياً بعد `prisma migrate` أو عبر SQL في migration:

```sql
-- فهرس مكاني لتسريع البحث الجغرافي
CREATE INDEX IF NOT EXISTS idx_donor_coords ON "DonorProfile" USING GIST (coords);

-- فهرس الفصيلة لتسريع فلتر البحث
CREATE INDEX IF NOT EXISTS idx_donor_blood ON "DonorProfile" (blood_type);

-- فهرس الطلبات المفتوحة فقط
CREATE INDEX IF NOT EXISTS idx_request_status ON "BloodRequest" (status) WHERE status = 'OPEN';
```

---

## 5. إصدارات الـ API

- **النمط المعتمد**: URI Versioning — `/api/v1/...`
- **عند التحديث**: إضافة `/api/v2/` مع الإبقاء على `/v1/` لدعم الإصدارات القديمة.

---

> [!IMPORTANT]
> جميع بيانات الهجرة الأولية (المواقع والبيانات التاريخية) موثقة في مستندات مستقلة:
> - **شجرة المواقع**: `seed_locations.md`
> - **خطة الهجرة**: `data_migration_plan.md`
> - **متغيرات البيئة**: `env_variables.md`
