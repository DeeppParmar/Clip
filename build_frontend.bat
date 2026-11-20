@echo off
title Build OpenShorts Frontend
echo ===================================================
echo Building OpenShorts Dashboard Frontend...
echo ===================================================

:: Mount virtual drive X: to bypass Windows C:\ root ACL restriction
subst X: "%~dp0" 2>nul

cd /d X:\dashboard
call npm run build

echo.
echo Build completed! Output is in dashboard\dist
