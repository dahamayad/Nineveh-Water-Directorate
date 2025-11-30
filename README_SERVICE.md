**WaterZummar — تشغيل الخادم كخدمة Windows (Windows Service)**

- **ملخص سريع**: يوجد ملف `service_wrapper.py` يحتوي على خدمة Windows مبنية باستخدام `pywin32`. يمكنك تثبيتها وتشغيلها عبر `install_service.ps1` (تشغيل كـ Administrator).

- **المتطلبات**:
  - Python 3.x مثبت وضمن PATH
  - صلاحيات Administrator لتثبيت الخدمة
  - مكتبة `pywin32` (السكربت سيثبتها آلياً)

- **خطوات سريعة (PowerShell كمسؤول)**:
```
cd C:\Users\Ayaddaham\Desktop\WaterZummar2026
.\install_service.ps1
```

- **أوامر بديلة (يدوياً)**:
  - تثبيت المكتبة:
```
python -m pip install pywin32
```
  - تثبيت الخدمة:
```
python service_wrapper.py install
```
  - بدء الخدمة:
```
python service_wrapper.py start
```
  - إيقاف الخدمة:
```
python service_wrapper.py stop
```
  - إزالة الخدمة:
```
python service_wrapper.py remove
```

- **بدائل إن لم تريد pywin32**:
  - NSSM (موصى به سهل الاستخدام): حمّل nssm، ثم:
```
nssm install WaterZummarServer "C:\Path\To\python.exe" "C:\Users\Ayaddaham\Desktop\WaterZummar2026\server.py"
nssm start WaterZummarServer
```
  - Scheduled Task (تشغيل عند الإقلاع): استخدم `schtasks` لإنشاء مهمة تعمل عند startup.

- **ملاحظات**:
  - الخدمة ستشغّل الخادم على `port 9000` بحسب `service_wrapper.py`.
  - راجع سجلات Windows Event (Event Viewer) للأخطاء المتعلقة بالخدمات أو سجل `server_out.log`/`server_err.log` إذا استخدمت البدائل.

---

**صور جوية حديثة (Satellite imagery) — خيارات وقيود**

- الوضع الحالي: الملف `index.html` يستخدم طبقة ESRI World Imagery عبر Leaflet، وهي طبقة عالية الجودة لكن توقيت تحديث الصور يختلف بحسب المنطقة.

- إذا تريد صوراً أحدث مثل Google Earth:
  - **Google Maps / Earth**: الصور ليست متاحة مجاناً للاستخدام المباشر كـ tiles بدون استخدام Google Maps Platform. تحتاج مفتاح API وفوترة، والشروط تمنع تنزيل/إعادة توزيع الصور. لاستخدامها داخل الواجهة (ضمن الشروط)، استخدم Google Maps JavaScript API أو مكتبة `leaflet.gridlayer.googlemutant` لعرض خلفية Google Maps داخل Leaflet.
    - مثال (باستخدام `leaflet.gridlayer.googlemutant`):
```
<script src="https://unpkg.com/leaflet.gridlayer.googlemutant/Leaflet.GoogleMutant.js"></script>
const googleSat = L.gridLayer.googleMutant({ type: 'satellite' }).addTo(map);
```
    - مطلوب مفتاح Google Maps API وقيود استخدام.

  - **Mapbox Satellite**: جودة ممتازة وتحديثات جيدة؛ يتطلب `access_token` (مقابل خدمة؛ تحقق من السعة والتكلفة).
    - مثال Tile URL لخرائط Mapbox (استبدل `YOUR_MAPBOX_TOKEN`):
```
L.tileLayer('https://api.mapbox.com/styles/v1/mapbox/satellite-v9/tiles/{z}/{x}/{y}?access_token=YOUR_MAPBOX_TOKEN', {
  tileSize: 512,
  zoomOffset: -1,
  attribution: '© Mapbox'
}).addTo(map);
```

  - **Bing Maps Aerial**: خيار آخر بجودة عالية مع مفتاح Bing Maps API.

  - **ESRI World Imagery**: ما تستخدمه حالياً — لا يحتاج مفتاحاً ويعمل مباشرة لكنه قد لا يكون الأحدث دائماً.

- **النصيحة العملية**:
  - للتحديث المستمر والاعتمادية في بيئة إنتاجية: استخدم Mapbox أو Google مع مفتاح مدفوع (حسب الميزانية) لأنهما يقدمان تحديثات وصيانة واضحة وسياسة استخدام واضحة.
  - تأكد من قراءة شروط الاستخدام والقيود الخاصة بكل مزود قبل العرض في تطبيقك.

