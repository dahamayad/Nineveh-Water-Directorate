# تشغيل نظام إدارة توزيع المياه
# Water Distribution Management System Launcher

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "   تشغيل نظام إدارة توزيع المياه" -ForegroundColor Yellow
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# التحقق من وجود Python
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✓ Python مثبت: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ خطأ: Python غير مثبت على النظام" -ForegroundColor Red
    Write-Host "الرجاء تثبيت Python من: https://www.python.org/downloads/" -ForegroundColor Yellow
    pause
    exit 1
}

# الانتقال إلى مجلد البرنامج
Set-Location $PSScriptRoot

# التحقق من وجود عملية تعمل على المنفذ 9000
$port9000 = netstat -ano | Select-String ":9000" | Select-String "LISTENING"

if ($port9000) {
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    Write-Host "✅ الخادم يعمل بالفعل!" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 الرابط:" -ForegroundColor Cyan
    Write-Host "   http://127.0.0.1:9000" -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host ""
    Write-Host "📋 انسخ الرابط أعلاه والصقه في المتصفح" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "🌐 فتح المتصفح..." -ForegroundColor Cyan
    Start-Sleep -Seconds 1
    Start-Process "http://127.0.0.1:9000"
    Write-Host ""
    pause
    exit 0
}

# بدء الخادم في الخلفية
Write-Host "🚀 بدء تشغيل الخادم..." -ForegroundColor Cyan
Start-Process -FilePath "python" -ArgumentList "server.py" -WindowStyle Hidden -RedirectStandardOutput "server_out.log" -RedirectStandardError "server_err.log"

# الانتظار قليلاً للتأكد من بدء الخادم
Write-Host "⏳ انتظار بدء الخادم..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

# التحقق من نجاح التشغيل
$serverRunning = netstat -ano | Select-String ":9000" | Select-String "LISTENING"

if (-not $serverRunning) {
    Write-Host ""
    Write-Host "❌ فشل بدء الخادم" -ForegroundColor Red
    Write-Host "الرجاء التحقق من ملف server_err.log للمزيد من التفاصيل" -ForegroundColor Yellow
    Write-Host ""
    if (Test-Path "server_err.log") {
        Write-Host "محتوى ملف الأخطاء:" -ForegroundColor Yellow
        Get-Content "server_err.log" | Write-Host -ForegroundColor Red
    }
    pause
    exit 1
}

Write-Host ""
Write-Host "✅ تم بدء الخادم بنجاح" -ForegroundColor Green
Write-Host "🌐 فتح المتصفح..." -ForegroundColor Cyan
Start-Sleep -Seconds 1

# فتح المتصفح الافتراضي
Start-Process "http://127.0.0.1:9000"

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "✅ البرنامج يعمل الآن!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "🌐 الرابط:" -ForegroundColor Cyan
Write-Host "   http://127.0.0.1:9000" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""
Write-Host "📋 انسخ الرابط أعلاه والصقه في المتصفح" -ForegroundColor Yellow
Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "💡 ملاحظات:" -ForegroundColor Cyan
Write-Host "   - لإيقاف الخادم: استخدم stop_server.ps1" -ForegroundColor White
Write-Host "   - النافذة ستبقى مفتوحة" -ForegroundColor White
Write-Host ""
pause
