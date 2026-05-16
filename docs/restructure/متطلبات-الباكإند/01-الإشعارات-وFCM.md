# 01 — الإشعارات و FCM

## ما يفعله العميل اليوم (يجب إيقافه)

| الموقع | السلوك | الخطر |
|--------|--------|-------|
| `lib/data/repositories/send_notfication_impl.dart` | HTTP إلى `https://fcm.googleapis.com/fcm/send` مع `registration_ids` ثابتة في الكود | تسريب tokens، إرسال غير مصرّح |
| `lib/presentation/pages/home_page.dart` | `pushNotificationsSpecificDevice`, `pushNotificationsGroupDevice`, `pushNotificationsAllUsers` | نفس المشكلة + **Server Key في العميل** |
| `lib/core/app_constants.dart` | `serverKey`, `senderId` | **سر يجب ألا يكون في APK** |
| Cubits | حفظ FCM token في مستند Firestore `donors.token` | يُستبدل بـ API |

## ما يوفّره الباكإند اليوم (**موجود**)

راجع [client-integration.md](../client-integration.md) و [blood-requests-and-notifications.md](../api/blood-requests-and-notifications.md).

| Endpoint | المسؤولية |
|----------|-----------|
| `POST /auth/device` | حفظ/ربط FCM token بـ `x-device-id` أو مستخدم |
| `POST /auth/logout` | فك ربط `deviceToken` |
| `POST /blood-requests` | السيرفر يطلق FCM في الخلفية (حد 5 أجهزة) |
| `GET /notifications` | قائمة in-app |
| `PATCH /notifications/:id/read` | قراءة |

**المطلوب من العميل:** استقبال FCM + تسجيل التوكن فقط — **لا إرسال**.

---

## منطق يجب أن يبقى / يُكتمل على السيرفر

### 1. استهداف متبرعين قرب طلب دم (موجود جزئياً)

| العميل القديم | الباكإند المستهدف |
|---------------|-------------------|
| اختيار tokens يدوياً من Firestore وإرسال HTTP | عند `POST /blood-requests`: اختيار أجهزة ضمن `radiusKm` + `bloodType` متوافق من جدول devices |

**تحقق من التنفيذ الحالي:**

- [ ] خوارزمية اختيار المستلمين (مسافة، `isShown`, `eligibleUntil`, `isNotificationsEnabled`)
- [ ] حد أقصى 5 أجهزة كما في الدليل
- [ ] payload: `{ "type": "BLOOD_REQUEST", "requestId": "..." }`
- [ ] تنظيف tokens الفاشلة (`registration-token-not-registered`)

### 2. إشعارات عامة / موضوع (Topic) — **مطلوب قرار**

العميل كان يرسل إلى `/topics/myTopic1` من الواجهة.

| خيار | وصف |
|------|-----|
| A | إلغاء الميزة من تطبيق المتبرع — إدارة من لوحة Admin لاحقاً |
| B | `POST /admin/notifications/broadcast` (ADMIN فقط) مع فلتر role/منطقة |
| C | إشعارات عامة عبر `POST /auth/device` بدون JWT (موجود للاستغاثات القريبة) — توثيق متى يُستخدم |

**توصية:** B أو A — لا topic من العميل.

### 3. إشعار لمستخدم واحد (يدوي من واجهة قديمة)

| العميل القديم | البديل |
|---------------|--------|
| `pushNotificationsSpecificDevice(token, title, body)` | **لا في العميل** — إن لزم: endpoint أدمن `POST /admin/notifications/send` بـ `userId` |

---

## بيانات Firestore → جداول API

| Firestore | الباكإند |
|-----------|----------|
| `donors.token` | جدول أجهزة مرتبط بـ `userId` عبر `/auth/device` |
| `notifications` collection (UI معطّل) | `GET /notifications` |

---

## معايير قبول (باكإند)

- [ ] لا حاجة لـ FCM Server Key في تطبيق الموبايل.
- [ ] كل إشعار push يمر عبر خدمة السيرفر (Firebase Admin SDK).
- [ ] طلب استغاثة يرسل إشعارات دون أي طلب من العميل غير `POST /blood-requests`.
- [ ] tokens المنتهية تُعلَّم `isFailed` ولا تُعاد محاولتها بلا حد.

## معايير قبول (عميل — للتنسيق)

- [ ] حذف `send_notfication_impl.dart` ودوال `home_page` للإرسال.
- [ ] حذف `serverKey` من `app_constants.dart`.
