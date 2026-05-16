# API — الملفات وإعدادات التطبيق

## POST /files/upload

**Auth:** JWT  
**Throttle:** 5 / 10 دقائق  
**Content-Type:** `multipart/form-data`

| Field | نوع | ملاحظة |
|-------|-----|--------|
| `file` | binary | jpg/png/webp، حد 2MB |
| `isPublic` | string | `"true"` أو `"false"` — صور الملف الشخصي العامة = true |

**201:**

```json
{
  "fileId": 12,
  "isPublic": true,
  "mimeType": "image/jpeg",
  "size": 150000
}
```

---

## GET /files/:fileId

**Auth:** اختياري

- `isPublic=true` → متاح
- `isPublic=false` → يتطلب JWT و`ownerId` مطابق أو `ADMIN`

**200:** يضبط `X-Accel-Redirect` لـ Nginx (في الإنتاج). العميل قد يحتاج فتح الرابط عبر API proxy وليس مباشرة.

---

## DELETE /files/:fileId

**Auth:** JWT — المالك أو ADMIN

حذف ناعم (`deletedAt`).

---

## GET /app-config

**Auth:** لا

**200:**

```json
{
  "app_name": "...",
  "home_header": "...",
  "min_app_version": "1.0.0",
  "home_slider": "[...]",
  "home_events": "[...]",
  "force_update_enabled": "false",
  "force_update_message": "",
  "store_url_android": "",
  "donation_cooldown_days": "90"
}
```

ملاحظات:

- المفاتيح أعلاه قد تظهر حسب ما خزّنه المشرف؛ عند أول `db:seed` يُنشئ المشروع قيماً افتراضية لـ `home_slider` و`home_events` (مصفوفات JSON فارغة) و`donation_cooldown_days` وحقول التحديث الاختيارية.
- لمفاتيح JSON (السلايدر/الفعاليات)، استخدم هياكل مستقرة بين الفريق؛ غالباً عناصر فيها مراجع `fileId` لمسار `GET /files/:fileId`.

---

## GET /app-config/:key

**Auth:** لا

**200:** `{ "key": "home_header", "value": "..." }`

---

## PUT /app-config/:key

**Auth:** JWT — `ADMIN`

```json
{ "value": "نص جديد أو JSON string" }
```

المشرف يمكنه إضافة أي مفتاح عبر `PUT /app-config/:key`، منها مثلاً:

| المفتاح | الغرض |
|---------|--------|
| `max_registrations_per_day` | عدد صحيح؛ عند تعيينه يُرفض `POST /auth/register` بـ **429** بعد بلوغ هذا العدد من تسجيلات `DONOR` في نفس يوم UTC |

---
