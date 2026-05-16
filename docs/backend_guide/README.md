# دليل الواجهات — أين أبدأ؟

1. **[client-integration.md](client-integration.md)** — JWT، الجهاز، FCM استقبالاً فقط، الاستغاثات، caches بسيطة.  
2. **[api/README.md](api/README.md)** — القواعد العامة (Base URL، throttling، أدوار، pagination).  
3. وحدة وحدة ضمن **`api/`** حسب الشاشة (مصادقة، بحث، مراكز، …).

## متعلق بالهجرة من Firebase

مجلد [متطلبات-الباكإند](../restructure/متطلبات-الباكإند/README.md) في `docs/restructure/` يشرح المنطق **القديم** في العميل وما يجب أن يتحمّله السيرفر؛ **ليس** بديلاً عن دليل API أعلاه.

## أمان مهمة لمطوري الموبايل

لا تضمّن **FCM Server Key** أو أي HTTP لـ `fcm.googleapis.com/fcm/send` في التطبيق. الاستقبال فقط؛ الإرسال عبر هذا الباكإند.
