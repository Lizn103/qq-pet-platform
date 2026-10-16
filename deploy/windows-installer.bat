:: ============================================================
:: QQ Pet Platform - Windows Installer (run as Administrator)
:: Generated 2026-10-17
:: ============================================================
@echo off
chcp 65001 >nul
title QQ Pet Platform Setup
echo ==========================================
echo   QQ Pet Platform v1.0.1 Installer
echo ==========================================

set APPDIR=%ProgramFiles%\QQ Pet
if not exist "%APPDIR%" mkdir "%APPDIR%"
copy /y "%~dp0..\..\build\qq-pet-server.exe" "%APPDIR%\" >nul
copy /y "%~dp0..\..\build\qq-pet-frontend.exe" "%APPDIR%\" >nul
copy /y "%~dp0nssm.exe" "%APPDIR%\" >nul

cd /d "%APPDIR%"
nssm install QQPetServer qq-pet-server.exe
nssm set QQPetServer AppDirectory "%APPDIR%"
nssm set QQPetFrontend AppDirectory "%APPDIR%"
set BACKEND_URL=http://127.0.0.1:2345
set FRONTEND_PORT=5173
set NO_OPEN=1
nssm install QQPetFrontend qq-pet-frontend.exe

echo Done. Backend: http://localhost:2345  Frontend: http://localhost:5173
pause
