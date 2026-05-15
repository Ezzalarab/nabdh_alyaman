# API — المشرف (`/admin`)

كل المسارات تتطلب **JWT + role ADMIN**.

## GET /admin/any

تحقق سريع من صلاحية ADMIN.

**200:** `{ "ok": true }`

---

## GET /admin/users

**Query:** `cursor?`, `limit?` (افتراضي 20)

**200:** `{ items, nextCursor, hasNextPage }` — `id, phone, email, role, status, createdAt`

---

## GET /admin/users/credentials

**للتطوير المحلي فقط** — يفك تشفير كلمات المرور. **لا تستخدم في إنتاج عام.**

**Query:** `id?` أو `identifier?` أو `limit?` (قائمة)

---

## PATCH /admin/users/:id/status

```json
{ "status": "BLOCKED" }
```

`status`: `ACTIVE` | `BLOCKED` | `DELETED`

---

## GET /admin/audit-logs

**Query:** `cursor?`, `limit?`

سجلات `AuditLog`.

---

## GET /admin/stats

**200:**

```json
{
  "totalDonors": 77,
  "totalCenters": 6,
  "openRequests": 2,
  "totalSearches": 150
}
```

---

## POST /admin/centers

إنشاء مركز — راجع [centers-and-inventory.md](centers-and-inventory.md).

---

## مسارات عامة (صحة)

| Method | Path | Auth |
|--------|------|------|
| GET | `/` | لا |
| GET | `/health` | لا — `{ status, database }` |

(خارج بادئة `auth` لكن تحت `/api/v1`)
