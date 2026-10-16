:: Quick manual start (no services)
@echo off
cd /d "%~dp0..\..\build"
start "" /min qq-pet-server.exe
set BACKEND_URL=http://127.0.0.1:2345
set FRONTEND_PORT=5173
set NO_OPEN=1
start "" /min qq-pet-frontend.exe
echo Backend http://localhost:2345  Frontend http://localhost:5173
