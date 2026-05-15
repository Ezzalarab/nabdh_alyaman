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
  "min_app_version": "1.0.0"
}
```

يُستدعى عند تشغيل التطبيق.

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

**200:** السجل المحدّث.
