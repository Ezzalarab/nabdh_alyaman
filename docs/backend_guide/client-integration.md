# دمج العميل (موبايل / ويب)

دليل محايد الإطار (Flutter، React، Vue، Angular، Kotlin، Swift، …).

## 1. Headers ثابتة

- **`x-device-id`**: UUID أو معرف ثابت لكل تثبيت — يُستخدم في Throttling وربط FCM.
- **`Authorization: Bearer <accessToken>`** بعد تسجيل الدخول.

## 2. الجلسة (Tokens)

| Token | العمر التقريبي | الاستخدام |
|-------|----------------|-----------|
| `accessToken` | 30 يوم (`JWT_EXPIRES_IN`) | كل طلب محمي |
| `refreshToken` | 365 يوم | `POST /auth/refresh` فقط |

**لا يتم تدوير refresh** — نفس refresh حتى انتهاء الصلاحية أو logout.

عند **401** على طلب محمي: جرّب `POST /auth/refresh` مرة، ثم أعد الطلب. إن فشل → شاشة تسجيل دخول.

```json
POST /auth/refresh
{ "refreshToken": "..." }

→ { "accessToken": "..." }
```

## 3. تسجيل الجهاز و FCM

عند فتح التطبيق (حتى بدون login):

```json
POST /auth/device
{
  "token": "<fcm_token>",
  "platform": "android" | "ios" | "web"
}
```

- مع JWT: يُربط التوكن بالمستخدم ويُفك ربطه من مستخدم سابق.
- بدون JWT: يُحفظ للإشعارات العامة (استغاثات قريبة).

**حدّث FCM token عند كل تسجيل دخول ناجح.**

عند logout أرسل `refreshToken` و`deviceToken`:

```json
POST /auth/logout
{ "refreshToken": "...", "deviceToken": "..." }
```

## 4. مسار المهاجرين من Firebase

1. `POST /auth/login` → إن كان `encryptedPassword` فارغاً:

```json
{ "statusCode": 403, "code": "NEEDS_FIREBASE_PASSWORD" }
```

2. العميل: Firebase Auth → `idToken`
3. `POST /auth/migration/complete`:

```json
{
  "phone": "9677XXXXXXXX",
  "idToken": "<firebase_id_token>",
  "newPassword": "StrongPass123!"
}
```

→ نفس استجابة login (`accessToken`, `refreshToken`, `role`, `user`).

## 5. التوجيه حسب الدور

بعد login اقرأ `role`:

| role | الواجهة |
|------|---------|
| `DONOR` | تطبيق المتبرع |
| `CENTER` | لوحة المركز |
| `ADMIN` | أدوات إدارية (أو تطبيق منفصل) |

لا تعتمد على إخفاء أزرار في الواجهة فقط — السيرفر يرفض 403.

## 6. Cache محلي للمواقع

`GET /locations` و `GET /locations/:stateId/districts` بيانات شبه ثابتة — خزّنها محلياً (SQLite / SharedPreferences / localStorage) لدعم ضعف الشبكة.

## 7. التوقيت

اعرض `createdAt` / `expiresAt` بتوقيت المستخدم؛ أرسل للسيرفر ISO 8601 UTC عند الحاجة.

## 8. الصور

1. اضغط في العميل قبل الرفع.
2. `POST /files/upload` — `multipart/form-data`: `file`, `isPublic` (string `"true"`/`"false"`).
3. للصورة الشخصية الظاهرة في البحث: `isPublic=true`.
4. استخدم `fileId` المُرجع في `imageUrl` للملف الشخصي.

## 9. طلب استغاثة

- مستخدم واحد = **طلب OPEN واحد** فقط — وإلا **429**.
- الرد فوري؛ الإشعارات تُرسل في الخلفية (5 أجهزة كحد أقصى).

## 10. ملاحظة Flutter (اختيارية)

- Router حسب `role` (GetX / AutoRoute / go_router).
- `intl` لتحويل UTC.
- Cache للمواقع كما في §6.

## مراجع

- [api/README.md](api/README.md)
- [authentication.md](api/authentication.md)
- التجريب اليدوي: [testing.md](../2-operations/testing.md)
