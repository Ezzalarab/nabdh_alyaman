# API — المراكز والمخزون

## GET /centers

**Auth:** لا — قائمة المراكز (بدون pagination افتراضياً).

**Query (اختياري):**

| Param | وصف |
|-------|-----|
| `stateId` | فلتر المحافظة |
| `districtId` | فلتر المديرية |
| `lat`, `lon`, `radiusKm` | معاً: الإبقاء على المراكز ضمن نصف قطر Kilometers (Haversine؛ يُهمَل مركز بلا إحداثيات) |

---

## GET /centers/:id

**Auth:** لا — بيانات مركز + `bloodStock`.

---

## GET /centers/:id/stock

**Auth:** لا — مخزون مركز محدد.

---

## GET /centers/me

**Auth:** JWT — `CENTER`

---

## PATCH /centers/me

**Auth:** JWT — `CENTER`

```json
{
  "name": "مستشفى الثورة",
  "imageUrl": "https://...",
  "lat": 15.37,
  "lon": 44.19,
  "locationId": 1001001,
  "stateId": 100,
  "districtId": 1001
}
```

---

## PATCH /centers/me/stock

**Auth:** JWT — `CENTER`

```json
{
  "bloodType": "A+",
  "change": 5,
  "reason": "تبرع جماعي"
}
```

`change` موجب = إضافة، سالب = خصم.

**200:**

```json
{ "success": true, "updatedStock": { "bloodType": "A+", "quantity": 10 } }
```

**400** إذا الخصم أكبر من المتوفر.

---

## GET /centers/me/stock/history

**Auth:** JWT — `CENTER`  
**Query:** `cursor?`, `limit?`

---

## POST /centers/me/donations

**Auth:** JWT — `CENTER`

```json
{
  "donorId": 42,
  "notes": "تبرع طوعي"
}
```

**201:** سجل `Donation`، ويُحدَّث `eligibleUntil` على ملف المتبرع إلى **الآن + N يوم** حيث N من مفتاح الإعداد `donation_cooldown_days` (افتراضي **90** عند إنشاء المفتاح عبر seed الأولي).  
يُرسل السيرفر أيضاً إشعار FCM شكراً للمتبرع (حتى **5** أجهزة فعّالة).

**400** إذا `donorId` لا يشير إلى مستخدم بدور `DONOR`.

---

## POST /admin/centers

**Auth:** JWT — `ADMIN`

```json
{
  "phone": "967771111111",
  "password": "CenterPass123!",
  "name": "مركز الدم المركزي",
  "locationId": 1001001,
  "stateId": 100,
  "districtId": 1001,
  "email": "center@example.com",
  "lat": 15.37,
  "lon": 44.19,
  "imageUrl": "https://..."
}
```

ينشئ `User` (CENTER) + `CenterProfile` + 8 صفوف `BloodStock` بكمية 0.

**مسار legacy:** `POST /centers` (نفس السلوك، ADMIN فقط).
