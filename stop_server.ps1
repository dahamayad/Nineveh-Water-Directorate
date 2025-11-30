# إيقاف خادم نظام إدارة توزيع المياه
# Stop Water Distribution Management System Server

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "  إيقاف خادم نظام إدارة توزيع المياه" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# البحث عن العملية التي تستخدم المنفذ 9000
$connection = netstat -ano | Select-String ":9000" | Select-String "LISTENING"

if (-not $connection) {
    Write-Host "⚠️  لا يوجد خادم يعمل على المنفذ 9000" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 0
}

# استخراج PID من النتيجة
$pid = ($connection -split '\s+')[-1]

Write-Host "🛑 إيقاف الخادم (PID: $pid)..." -ForegroundColor Yellow

try {
    Stop-Process -Id $pid -Force -ErrorAction Stop
    Write-Host ""
    Write-Host "✅ تم إيقاف الخادم بنجاح" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host ""
    Write-Host "❌ فشل إيقاف الخادم" -ForegroundColor Red
    Write-Host "الخطأ: $_" -ForegroundColor Red
    Write-Host ""
    pause
    exit 1
}

pause
