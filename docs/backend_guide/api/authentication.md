# API — المصادقة (`/auth`)

## POST /auth/login

**Auth:** لا  
**Throttle:** 10 / 15 دقيقة

**Body:**

```json
{
  "identifier": "967771234567",
  "password": "your-password"
}
```

`identifier` = رقم يمني أو بريد إلكتروني.

**201 نجاح:**

```json
{
  "accessToken": "eyJ...",
  "refreshToken": "...",
  "role": "DONOR",
  "user": { "id": 1, "phone": "967771234567", "role": "DONOR" }
}
```

**403 مهاجر بلا كلمة مرور محلية:**

```json
{
  "statusCode": 403,
  "code": "NEEDS_FIREBASE_PASSWORD",
  "message": "..."
}
```

**401** كلمة مرور خاطئة أو مستخدم غير موجود. **403** حساب `BLOCKED`.

---

## POST /auth/register

**Auth:** لا — **DONOR فقط**

```json
{
  "fullName": "أحمد محمد",
  "phone": "967771234567",
  "password": "min6chars",
  "bloodType": "O+",
  "gender": "MALE",
  "email": "optional@example.com",
  "locationId": 1001,
  "stateId": 100,
  "districtId": 1001,
  "lat": 15.37,
  "lon": 44.19
}
```

`gender`: `MALE` | `FEMALE`

**201:** نفس شكل login.

**400** رقم موجود — وجّه المستخدم لتسجيل الدخول أو نسيان كلمة المرور.

---

## POST /auth/refresh

**Auth:** لا

```json
{ "refreshToken": "..." }
```

**201:**

```json
{ "accessToken": "eyJ..." }
```

**401** توكن ملغى أو منتهٍ.

---

## POST /auth/migration/complete

**Auth:** لا — يتطلب Firebase Admin على السيرفر

```json
{
  "phone": "967771234567",
  "idToken": "<firebase_id_token>",
  "newPassword": "NewStrongPass123!"
}
```

**201:** نفس شكل login.

---

## POST /auth/logout

**Auth:** JWT

```json
{
  "refreshToken": "...",
  "deviceToken": "<fcm_token>"
}
```

**201:** `{ "success": true }`

---

## DELETE /auth/account

**Auth:** JWT — يحذف الحساب والتوابع (مع أرشفة).

**200:** `{ "success": true }`

---

## POST /auth/device

**Auth:** اختياري (JWT إن وُجد)

```json
{
  "token": "<fcm_registration_token>",
  "platform": "android"
}
```

`platform`: `android` | `ios` | `web` (نص حر في التنفيذ)

---

## POST /auth/forgot-password

**Auth:** لا — **Throttle:** 3 / ساعة

```json
{ "phone": "967771234567" }
```

**200** دائماً (حتى إن لم يوجد مستخدم — منع الاستكشاف).

---

## POST /auth/verify-otp

```json
{
  "phone": "967771234567",
  "code": "123456"
}
```

**200:**

```json
{ "resetToken": "...", "expiresInMinutes": 15 }
```

**400** رمز خاطئ (بعد 5 محاولات يُرفض).

---

## POST /auth/reset-password

```json
{
  "resetToken": "...",
  "newPassword": "NewPass123!"
}
```

**200:** `{ "success": true }`
