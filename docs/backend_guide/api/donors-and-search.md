# API — المتبرعون، البحث، المواقع

## GET /donors/me

**Auth:** JWT — `DONOR`

**200:** ملف `DonorProfile` + بيانات `User` المرتبطة.

---

## PATCH /donors/me

**Auth:** JWT — `DONOR`

**Body** (كل الحقول اختيارية):

```json
{
  "fullName": "أحمد",
  "bloodType": "A+",
  "gender": "MALE",
  "birthDate": "1990-01-15",
  "stateId": 100,
  "districtId": 1001,
  "locationId": 1001001,
  "lat": 15.37,
  "lon": 44.19,
  "isShown": true,
  "isPhoneShown": false,
  "isNotificationsEnabled": true,
  "isGpsOn": true
}
```

---

## GET /donors/me/donations

**Auth:** JWT — `DONOR`  
**Query:** `cursor?`, `limit?` (افتراضي 20)

**200:** `{ items, nextCursor, hasNextPage }`

---

## GET /donor-search

**Auth:** اختياري  
**Query:**

| Param | مطلوب | ملاحظة |
|-------|--------|--------|
| `bloodType` | نعم | مثل `A+` |
| `lat` | نعم | |
| `lon` | نعم | |
| `stateId` | لا | فلتر إضافي |
| `radiusKm` | لا | افتراضي 20، أقصى 100 |

**200:** مصفوفة (حتى 100)، مرتبة بالمسافة:

```json
[
  {
    "userId": 5,
    "fullName": "...",
    "bloodType": "A+",
    "imageUrl": "...",
    "phone": "9677..." ,
    "distance_km": 1.2
  }
]
```

`phone` = `null` إذا `isPhoneShown=false`.  
يُستبعد من لديهم `eligibleUntil` في المستقبل أو `isShown=false`.

---

## GET /donor-search/manual

**Auth:** اختياري  
**Query:** `bloodType`, `stateId?`, `districtId?`, `cursor?`, `limit?` (افتراضي 20)

**200:**

```json
{
  "items": [ { "userId", "fullName", "bloodType", "imageUrl", "phone" } ],
  "nextCursor": 10,
  "hasNextPage": true
}
```

---

## GET /locations

**Auth:** لا

**200:** قائمة محافظات (`level=STATE`).

---

## GET /locations/:stateId/districts

**Auth:** لا

**200:** مديريات المحافظة `stateId`.

مثال: `/locations/100/districts` (أمانة العاصمة).
