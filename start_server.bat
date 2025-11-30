@echo off
echo Starting Water Distribution Management System Server...
cd /d "%~dp0"
rem Start server in a new window and log output to server.log
rem Uses cmd /k so the new window stays open and shows runtime errors
rem Use PowerShell to start Python as a separate process with redirected logs.
rem This is more reliable than `start` and works with the current PATH.
powershell -NoProfile -Command "Start-Process -FilePath python -ArgumentList 'server.py' -WorkingDirectory '%~dp0' -RedirectStandardOutput '%~dp0server_out.log' -RedirectStandardError '%~dp0server_err.log' -WindowStyle Minimized -PassThru | ForEach-Object { Write-Host 'Started server PID:' $_.Id }"
echo Server start requested. Check `server_out.log` and `server_err.log` for output.
echo To stop the server: find the PID and run `taskkill /PID <pid> /F` or use PowerShell `Stop-Process -Id <pid>`.
pause