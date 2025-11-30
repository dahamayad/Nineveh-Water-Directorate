@echo off
chcp 65001 >nul
echo ====================================
echo إيقاف خادم نظام إدارة توزيع المياه
echo ====================================
echo.

REM البحث عن العملية التي تستخدم المنفذ 9000
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :9000 ^| findstr LISTENING') do (
    set PID=%%a
)

if not defined PID (
    echo ⚠️  لا يوجد خادم يعمل على المنفذ 9000
    pause
    exit /b 0
)

echo 🛑 إيقاف الخادم (PID: %PID%)...
taskkill /PID %PID% /F >nul 2>&1

if errorlevel 1 (
    echo ❌ فشل إيقاف الخادم
    pause
    exit /b 1
)

echo ✅ تم إيقاف الخادم بنجاح
echo.
pause
