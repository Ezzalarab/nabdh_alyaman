# الدليل التفصيلي لمخطط قاعدة البيانات (Exhaustive Schema Specification)

هذا المستند يقدم المخطط البرمجي النهائي (Prisma Schema) والعلاقات بين الجداول، مع شرح كل حقل والقيود المفروضة عليه.

---

## 1. تصميم الجداول باستخدام Prisma Syntax

### أ. جدول المستخدمين (User)
المسؤول عن تسجيل الدخول والصلاحيات.
```prisma
model User {
  id                String   @id @default(uuid())
  email             String?  @unique
  phone             String   // البيانات مشفرة (AES-256)
  phoneHash         String   @unique // الفهرس الأعمى (HMAC-SHA256) للبحث وتسجيل الدخول
  passwordHash      String
  role              Role     @default(DONOR)
  status            Status   @default(ACTIVE)
  isEmailVerified   Boolean  @default(false)
  isPhoneVerified   Boolean  @default(false)
  fcmToken          String?  @db.Text
  createdAt         DateTime @default(now())
  updatedAt         DateTime @updatedAt

  // العلاقات
  donorProfile      DonorProfile?
  centerProfile     CenterProfile?
  notifications     Notification[]
  searchLogs        SearchLog[]
  files             StoredFile[]
}

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
```

### ب. جدول ملف المتبرع (DonorProfile)
يحتوي على البيانات الشخصية والمكانية.
```prisma
model DonorProfile {
  userId        String   @id @map("user_id")
  fullName      String
  bloodType     String   @db.VarChar(5)
  gender        Gender
  birthDate     DateTime?
  locationId    Int
  
  // حقلCoords يتم التعامل معه عبر SQL Raw في Prisma للهجرة المكانية
  // coords      Unsupported("geography(Point, 4326)")? 

  isShown       Boolean  @default(true)
  isPhoneShown  Boolean  @default(true)
  isGpsOn       Boolean  @default(true)
  imageUrl      String?

  user          User     @relation(fields: [userId], references: [id])
  location      Location @relation(fields: [locationId], references: [id])
  donations     Donation[]
}

enum Gender {
  MALE
  FEMALE
}
```

### ج. هيكلية المواقع (Location)
لحل مشكلة البيانات الثابتة في التطبيق.
```prisma
model Location {
  id        Int      @id
  name      String
  level     LocationLevel
  parentId  Int?
  emoji     String?
  emojiU    String?

  parent    Location?  @relation("LocationHierarchy", fields: [parentId], references: [id])
  children  Location[] @relation("LocationHierarchy")
  
  donors    DonorProfile[]
  centers   CenterProfile[]
  logs      SearchLog[]
}

model StoredFile {
  id           String   @id @default(uuid())
  originalName String
  storedPath   String
  mimeType     String
  size         Int
  isPublic     Boolean  @default(false)
  ownerId      String?
  createdAt    DateTime @default(now())

  // ربط الملف بصاحبه
  user         User?    @relation(fields: [ownerId], references: [id])
}

enum LocationLevel {
  COUNTRY
  STATE
  CITY
}
```

### د. سجل المخزون والعمليات (Inventory & Logs)
```prisma
model BloodStock {
  id        Int      @id @default(autoincrement())
  centerId  String
  bloodType String   @db.VarChar(5)
  quantity  Int      @default(0)
  updatedAt DateTime @updatedAt

  center    CenterProfile @relation(fields: [centerId], references: [userId])
}

model StockTransaction {
  id        Int      @id @default(autoincrement())
  centerId  String
  bloodType String
  change    Int      // (مثلاً +5 أو -3)
  reason    String?
  createdAt DateTime @default(now())
}
```

### هـ. جدول طلبات الاستغاثة (BloodRequest)
لإدارة نداءات الاستغاثة العاجلة التي يطلقها المستخدمون.
```prisma
model BloodRequest {
  id            String   @id @default(uuid())
  requesterId   String
  bloodType     String   @db.VarChar(5)
  hospitalName  String
  patientName   String?
  unitsNeeded   Int      @default(1)
  urgencyLevel  Urgency  @default(NORMAL)
  status        RequestStatus @default(OPEN)
}
```

---

## 2. الأمن وتشفير البيانات (Security & Encryption)

لحماية بيانات المستخدمين في حال حدوث تسريب لقاعدة البيانات، سنتبع المعايير التالية:

1.  **كلمات المرور**: تشفير باستخدام `Argon2` أو `Bcrypt` (لا تخزن أبداً كـ Plain text).
2.  **أرقام الهواتف**: سيتم تشفير الرقم باستخدام **AES-256-CBC/GCM** قبل الحفظ. ولتفعيل نظام تسجيل الدخول، سيتم استخدام **فهرس أعمى (Blind Index)** عبر استخراج `HMAC-SHA256` للرقم وتخزينه في حقل `phoneHash` لغرض المقارنة (Querying) فقط.
3.  **بيانات الموقع الجغرافي**: تحويل كافة نصوص المواقع في Firebase إلى إحداثيات حقيقية باستخدام PostGIS لضمان دقة البحث.

---

## 3. معايير التوقيت والمواقع (Timezone & Geospatial)

1.  **المعيار العالمي**: كافة حقول التاريخ تُخزن بصيغة **UTC** لضمان الاتساق.
2.  **PostgreSQL Native**: استخدام نوع `TIMESTAMPTZ` لضمان معالجة فروق التوقيت برمجياً.
3.  **PostGIS**: استخدام `Geography(Point, 4326)` لعمليات البحث الجغرافي.

---

## 4. الفهارس والتحسينات (Indexes & Constraints)

### أ. الفهرسة المكانية للحفاظ على المعالج (CPU)
لضمان سرعة البحث وعدم إرهاق السيرفر بعمليات المسح التسلسلي، يجب تنفيذ استعلام الفهرس المكاني التالي في قاعدة البيانات:
```sql
CREATE INDEX idx_user_coords ON "DonorProfile" USING GIST (coords);
```

### ب. استراتيجية إصدارات الـ API (Versioning Strategy)
- **الإشكالية**: مستقبلاً، عند تحديث هيكلية قاعدة البيانات، قد تتوقف الإصدارات القديمة من التطبيق عن العمل.
- **الحل المقترح**: اعتماد URI Versioning (مثال: `/api/v1/...`).
