# الدليل التفصيلي لتدفق العمليات (Process Flows)

يقدم هذا المستند شرحاً دقيقاً لكل خطوة منطقية في العمليات الحساسة للتطبيق، بما فيها معالجة الحالات الاستثنائية.

---

## 1. تدفق المصادقة (Auth Flow)

### أ. تسجيل الدخول (Login)

```
Client → POST /api/v1/auth/login { phone, password }
         ↓
[Backend]
1. تنسيق رقم الهاتف (+967...)
2. البحث في DB: WHERE phone = نفس الرقم المنسق
   ↓
   [لم يُوجد] → 401 Unauthorized
         ↓
3. مقارنة كلمة المرور: bcryptjs.compare(input, user.passwordHash)
   ↓
   [خاطئة] → 401 Unauthorized
         ↓
4. التحقق من حالة الحساب: user.status
   ↓
   [BLOCKED] → 403 Forbidden
   [PENDING] → 403 + رسالة "الحساب قيد المراجعة"
         ↓
5. توليد JWT: { sub: user.id, role: user.role }
6. إرجاع: { accessToken, role, profile }
```

### ب. حماية الـ Endpoints (Guard Flow)

```
Request + Header: "Authorization: Bearer <token>"
         ↓
JwtAuthGuard → فك تشفير التوكن
   ↓
   [فاشل/منتهي] → 401 Unauthorized
         ↓
RolesGuard → التحقق من role في الـ payload
   ↓
   [غير مصرح] → 403 Forbidden
         ↓
تنفيذ Handler المطلوب ✓
```

### ج. إعادة ضبط كلمة المرور (لمستخدمي الهجرة)

```
Client → POST /api/v1/auth/reset-password { phone, newPassword }
         ↓
1. التحقق من وجود الهاتف في DB (WHERE phone = ?)
2. إذا كان passwordHash == MIGRATION_PLACEHOLDER:
   → قبول الإعادة وتحديث الـ hash
3. إذا كان passwordHash حقيقياً:
   → مطالبة بكلمة المرور القديمة أولاً (تدفق "تغيير كلمة المرور")
```

---

## 2. منطق البحث الذكي المتوسع (Smart Geospatial Search)

```
Client → GET /api/v1/donor-search?bloodType=A+&lat=15.35&lon=44.20
         ↓
[المرحلة 1] ST_DWithin → نطاق 5 كم
   ↓
   [نتائج >= 5] → إرجاع النتائج ✓
         ↓
[المرحلة 2] ST_DWithin → توسيع إلى 10 كم
   ↓
   [نتائج >= 1] → إرجاع النتائج ✓
         ↓
[المرحلة 3] البحث في كامل المديرية (locationId = district)
   ↓
   [نتائج >= 1] → إرجاع النتائج ✓
         ↓
[المرحلة 4] البحث في كامل المحافظة (locationId = state)
   ↓
   [لا نتائج] → إرجاع: { results: [], message: "لا يوجد متبرع في محافظتك" }

--- ملاحظات ---
- فلتر isShown = true دائماً مفعّل
- fلتر الفصيلة يبحث بالتوافق: A+ يقبل O+ و A+ (قابلية التبرع)
- حد النتائج: 50 متبرع كحد أقصى في كل استجابة
```

---

## 3. دورة حياة طلب الاستغاثة (Emergency Request Lifecycle)

```
[1. إنشاء الطلب]
Client → POST /api/v1/blood-requests { bloodType, locationId, hospitalName, urgency }
         ↓
Backend: إنشاء سجل BloodRequest بـ status=OPEN

[2. محرك البث (Broadcast Engine)]
Backend يُشغّل في الخلفية (async):
         ↓
أ. البحث عن المتبرعين المطابقين:
   - نفس الفصيلة + isShown=true + isGpsOn=true
   - مرتبون بالقرب الجغرافي (5km → 10km → محافظة)
         ↓
ب. استخراج FCM Tokens
         ↓
ج. إرسال بدفعات (500 توكن/دفعة) عبر FCM Admin SDK
         ↓
د. تنظيف التوكنات الميتة (NotRegistered error → حذف fcmToken)

[3. الاكتمال]
المستخدم → PATCH /api/v1/blood-requests/:id/status { status: "FULFILLED" }
         ↓
Backend: تحديث الحالة + إرسال إشعار شكر للمتبرعين الذين استجابوا

[4. الانتهاء التلقائي (Expiry)]
إذا مرّ وقت expiresAt دون استيفاء:
         ↓
Backend (Cron Job): تحديث status → EXPIRED
```

---

## 4. دورة حياة تحديث المخزون (Inventory Update)

```
Client (CENTER role) → PATCH /api/v1/centers/:id/stock
Body: { bloodType: "A+", newQuantity: 15 }
         ↓
[Backend]
1. التحقق: هل user.id يملك هذا المركز؟
   ↓
   [لا] → 403 Forbidden
         ↓
2. Atomic Update في PostgreSQL:
   UPDATE "BloodStock" SET quantity = 15 WHERE centerId = ? AND bloodType = ?
         ↓
3. إنشاء سجل في StockTransaction:
   { centerId, bloodType, change: (15 - oldQuantity), reason: "تحديث يدوي" }
         ↓
4. إرجاع: { success: true, updatedStock }
```

---

## 5. نظام معالجة الملفات الآمن (Secure File Proxy)

```
Client → GET /api/v1/files/:fileId
Header: Authorization: Bearer <token>
         ↓
[Backend]
1. جلب سجل StoredFile من DB
   ↓
   [غير موجود] → 404 Not Found
         ↓
2. إذا isPublic = true → متابعة
   إذا isPublic = false:
   - التحقق من أن ownerId == user.id أو role == ADMIN
   ↓
   [غير مصرح] → 403 Forbidden
         ↓
3. إرسال Header لـ Nginx:
   X-Accel-Redirect: /protected-uploads/:storedPath
   Content-Type: :mimeType
   Cache-Control: max-age=86400, private
         ↓
Nginx يُرسل الملف مباشرة من القرص (بدون تحميله في Node.js)
```

---

## 6. تدفق إعادة ضبط كلمة المرور (Password Reset — مستقبلاً)

> هذا التدفق مبسّط في المرحلة الأولى (لا SMS OTP). سيُفعَّل لاحقاً.

```
[المرحلة الأولى — مؤقت]
المستخدم يتصل بالدعم لإعادة ضبط كلمة المرور يدوياً من لوحة الـ Admin.

[المستقبل — OTP عبر SMS]
POST /api/v1/auth/request-otp { phone }
         ↓
Backend: توليد OTP عشوائي + إرساله عبر SMS API
         ↓
POST /api/v1/auth/verify-otp { phone, otp, newPassword }
         ↓
Backend: التحقق من OTP + تحديث passwordHash
```
