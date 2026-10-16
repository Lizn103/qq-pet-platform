:: Re-register/repair the two Windows services (run as Administrator)
@echo off
chcp 65001 >nul
cd /d "%~dp0.."
nssm install QQPetServer qq-pet-server.exe 2>nul
nssm set QQPetServer AppDirectory "%CD%"
nssm install QQPetFrontend qq-pet-frontend.exe 2>nul
nssm set QQPetFrontend AppDirectory "%CD%"
set BACKEND_URL=http://127.0.0.1:2345
set FRONTEND_PORT=5173
set NO_OPEN=1
nssm start QQPetServer 2>nul
nssm start QQPetFrontend 2>nul
echo Services OK.
