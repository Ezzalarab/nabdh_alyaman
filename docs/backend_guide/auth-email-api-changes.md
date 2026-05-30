# تغييرات API — البريد والتحقق واستعادة كلمة المرور

> **للمطور:** هذا الملف يلخّص **التغييرات فقط** التي تحتاج تعديلاً في تطبيق الواجهات.  
> التفاصيل الكاملة لكل مسار: [api/authentication.md](api/authentication.md)

**Base URL:** `/api/v1` — جميع المسارات أدناه نسبية بعده.

---

## 1. حقول جديدة في استجابة المستخدم

تظهر في `user` ضمن:

- `POST /auth/login`
- `POST /auth/register`
- `POST /auth/refresh` (**جديد:** `refresh` يُرجع `user` الآن)

| الحقل | النوع | المعنى |
|--------|--------|--------|
| `email` | `string \| null` | البريد المسجّل |
| `emailMissing` | `boolean` | `true` = الحساب بلا بريد (حسابات قديمة) |
| `emailVerified` | `boolean` | `true` بعد التحقق عبر `/auth/email/verify` |

**مثال:**

```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "role": "DONOR",
  "user": {
    "id": 1,
    "phone": "967771234567",
    "role": "DONOR",
    "email": "user@example.com",
    "emailMissing": false,
    "emailVerified": false
  }
}
```

**`GET /donors/me`:** كائن `user` يتضمن أيضاً `emailMissing` و `emailVerified`.

> التحقق من البريد **لا يمنع** تسجيل الدخول — شارة للواجهة فقط.

---

## 2. مسارات تغيّر سلوكها (تحديث مطلوب)

### `POST /auth/register`

| قبل | بعد |
|-----|-----|
| `email` اختياري | **`email` إلزامي** |

```json
{
  "fullName": "...",
  "phone": "967771234567",
  "email": "user@example.com",
  "password": "...",
  "bloodType": "O+",
  "gender": "MALE"
}
```

**400** إن نقص `email` أو كان الهاتف/البريد مكرراً.

---

### `POST /auth/forgot-password`

| قبل | بعد |
|-----|-----|
| `{ "phone": "..." }` فقط | **`identifier`** = هاتف يمني **أو** بريد |

```json
{ "identifier": "967771234567" }
```

```json
{ "identifier": "user@example.com" }
```

**توافق:** `{ "phone": "967771234567" }` ما زال مقبولاً مؤقتاً.

- OTP يُرسل **دائماً إلى البريد المسجّل** على الحساب (ليس SMS).
- **201** `{ "success": true }` حتى لو المستخدم غير موجود (منع الاستكشاف).
- **Throttle:** 3 / ساعة

---

### `POST /auth/verify-otp`

| قبل | بعد |
|-----|-----|
| `phone` + `code` | **`identifier`** + `code` (نفس منطق forgot) |

```json
{
  "identifier": "user@example.com",
  "code": "123456"
}
```

**201:** `{ "resetToken": "..." }` — صالح 15 دقيقة.

**400** رمز خاطئ؛ بعد 5 محاولات: `OTP attempts exceeded`.

---

### `POST /auth/reset-password`

- الـ body **لم يتغيّر:** `{ "resetToken", "newPassword" }`.
- داخلياً `resetToken` أصبح مربوطاً بـ `userId` (لا يؤثر على شكل الطلب من الواجهة).

---

### `POST /auth/login`

- **لم يتغيّر** الـ body: `{ "identifier", "password" }`.
- اقرأ الحقول الجديدة في `user` (أعلاه).

---

## 3. مسارات جديدة (شاشات جديدة)

### إكمال البريد — حسابات قديمة

**متى:** بعد login/register/refresh إذا `emailMissing === true`.

```
POST /auth/profile/email
Authorization: Bearer <accessToken>
```

```json
{ "email": "user@example.com" }
```

**201:** `{ "success": true }` — **مرة واحدة فقط** (عندما لم يكن للحساب بريد).

**Throttle:** 5 / ساعة

---

### تحقق البريد (اختياري — يُفعَّل من الواجهة)

**متى:** المستخدم يختار «تحقق من بريدي» من الإعدادات أو شاشة مخصصة.

**الخطوة 1 — إرسال OTP:**

```
POST /auth/email/send-verification
Authorization: Bearer <accessToken>
```

بدون body.

**201:** `{ "success": true }`  
**400** لا يوجد بريد على الحساب  
**503** إعداد البريد على السيرver غير مكتمل  
**Throttle:** 3 / ساعة

**الخطوة 2 — تأكيد الرمز:**

```
POST /auth/email/verify
Authorization: Bearer <accessToken>
```

```json
{ "code": "123456" }
```

**201:** `{ "success": true }` → بعدها `emailVerified: true` في login/refresh.

---

## 4. مسارات بدون تغيير (لا حاجة لتعديل)

- `POST /auth/logout`
- `DELETE /auth/account`
- `POST /auth/device`
- `POST /auth/migration/complete`

---

## 5. لوحة المشرف (إن وُجدت)

**`POST /admin/centers`:** `email` أصبح **إلزامي** عند إنشاء حساب مركز.

---

## 6. تدفقات الواجهة المقترحة

```text
تسجيل جديد
  → register (email إلزامي)
  → user.emailVerified = false (طبيعي)

حساب قديم بلا بريد
  → login → emailMissing: true
  → شاشة «أكمل بريدك» → POST /auth/profile/email
  → (اختياري) send-verification → verify

تحقق لاحق
  → send-verification → verify
  → emailVerified: true

نسيان كلمة المرور
  → حقل واحد identifier (هاتف أو إيميل — مثل login)
  → forgot-password → verify-otp → reset-password
  → OTP يصل على البريد المسجّل
```

---

## 7. التجريب — لا يوجد endpoint اختبار بريد

لا يوجد مسار مثل `/test-email`. للتجريب:

| الهدف | المسار |
|-------|--------|
| اختبار إرسال SMTP | `POST /auth/email/send-verification` (JWT + حساب له بريد) |
| اختبار OTP + reset | `forgot-password` → `verify-otp` → `reset-password` |

**ملاحظة:** `forgot-password` قد يُرجع نجاحاً بصمت إن لم يوجد مستخدم أو لا بريد — `send-verification` أوضح للتشخيص (**503** = إعداد بريد ناقص).

---

## 8. Throttling (ملخص)

| المسار | الحد |
|--------|------|
| `POST /auth/forgot-password` | 3 / ساعة |
| `POST /auth/profile/email` | 5 / ساعة |
| `POST /auth/email/send-verification` | 3 / ساعة |
| `POST /auth/login` | 10 / 15 دقيقة |

يُفضَّل إرسال `x-device-id` ثابت مع كل الطلبات.

---

## 9. checklist للمطور

- [ ] نموذج التسجيل: `email` إلزامي
- [ ] قراءة `emailMissing` / `emailVerified` بعد login و refresh
- [ ] شاشة إكمال البريد → `POST /auth/profile/email`
- [ ] شاشة تحقق اختياري → `send-verification` + `verify`
- [ ] نسيان كلمة المرور: حقل `identifier` (ليس إيميل داخل `phone`)
- [ ] `verify-otp`: `identifier` + `code`
- [ ] `GET /donors/me`: عرض حالة التحقق من `user`
- [ ] إنشاء مركز (Admin): `email` إلزامي

---

**آخر تحديث:** يتوافق مع migration `auth_email_otp` — راجع [authentication.md](api/authentication.md) لأي اختلاف مستقبلي.
