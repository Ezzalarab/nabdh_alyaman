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

**أمان:** لا تضمّن FCM Legacy Server Key في التطبيق ولا تستدعِ `fcm.googleapis.com/fcm/send`. الإرسال من السيرفر فقط؛ العميل يستقبل ويُحدّث التوكن عبر `POST /auth/device`.

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

### سياسة عميل Flutter (نبض اليمن)

تطبيق Flutter **لا** يستدعي `POST /auth/migration/complete` ولا يضمّن Firebase Auth SDK. عند `NEEDS_FIREBASE_PASSWORD` يوجّه المستخدم إلى **OTP / نسيت كلمة المرور** فقط. راجع [`04-المصادقة-والهجرة.md`](../restructure/المرحلة-1-المصادقة/04-المصادقة-والهجرة.md) و[`docs/developer-guide.md`](../developer-guide.md).

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
- الرد فوري؛ الإشعارات تُرسل في الخلفية (حد 5 أجهزة).
- يستهدف السيرفر المتبرعين **بفصائل متوافقة** مع فصيلة المريض الطالبة (ليست المطابقة الحرفية فقط) عند اختيار المستلمين.

## 10. ملاحظة Flutter (اختيارية)

- Router حسب `role` (GetX / AutoRoute / go_router).
- `intl` لتحويل UTC.
- Cache للمواقع كما في §6.

## مراجع

- [README دليل API](api/README.md)
- [authentication.md](api/authentication.md)
- التجريب اليدوي والتشغيل: وثائق مستودع الباكإند (غير مضمّنة في تطبيق Flutter)؛ راجع فريق الخادم أو `docs/backend_docs/overview.md`.
