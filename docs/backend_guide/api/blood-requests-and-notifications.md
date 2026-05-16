# API — الاستغاثة والإشعارات

## POST /blood-requests

**Auth:** JWT (أي دور مسجّل)  
**Throttle:** 5 / دقيقة

```json
{
  "bloodType": "O+",
  "locationId": 1001001,
  "hospitalName": "مستشفى الثورة",
  "lat": 15.37,
  "lon": 44.19,
  "patientName": "اختياري",
  "unitsNeeded": 2,
  "urgency": "HIGH"
}
```

`urgency`: `NORMAL` | `HIGH` | `CRITICAL` (اختياري)

**201:** سجل الطلب بحالة `OPEN`. `expiresAt` يُحسب تلقائياً (+24 ساعة).  
FCM يُطلق في الخلفية؛ يقتصر على **5** أجهزة، ويستهدف متبرعين **بفصائل متوافقة** مع `bloodType` الطلب (بحث متعدد الفصائل دون تسجيل كعملية بحث يدوية).

**429** إن وُجد طلب `OPEN` آخر لنفس المستخدم.

---

## GET /blood-requests

**Auth:** لا  
**Query:** `bloodType?`, `stateId?`, `cursor?`, `limit?`

قائمة الطلبات المفتوحة (cursor pagination).

---

## GET /blood-requests/my

**Auth:** JWT  
**Query:** `cursor?`, `limit?`

طلبات المستخدم الحالي.

---

## GET /blood-requests/:id

**Auth:** لا — تفاصيل طلب.

---

## PATCH /blood-requests/:id/status

**Auth:** JWT — صاحب الطلب أو `ADMIN`

```json
{ "status": "FULFILLED" }
```

| status | ملاحظة |
|--------|--------|
| `FULFILLED` | إغلاق ناجح |
| `CANCELLED` | إلغاء |

**403** لمستخدم آخر. لا إعادة فتح طلب مغلق.

---

## GET /notifications

**Auth:** JWT  
**Query:** `cursor?`, `limit?` (افتراضي 20)

إشعارات المستخدم من DB (ليس FCM فقط).

---

## PATCH /notifications/:id/read

**Auth:** JWT

---

## PATCH /notifications/read-all

**Auth:** JWT

---

## سلوك FCM (للعميل)

- payload `data.type` = `BLOOD_REQUEST` و `data.requestId`
- السيرفر يعلّم التوكنات المنتهية `isFailed=true` عند `registration-token-not-registered`
- المتبرعون المعرّضون للإشعار يُقتطعون من مجموعة فصائل **متوافقة طبياً** مع نوع الطلب (مثل توسعة `includeCompatible` في بحث المتبرعين)
