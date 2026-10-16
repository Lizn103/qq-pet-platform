:: Build Go backend -> build/qq-pet-server.exe (requires Go 1.26+)
@echo off
cd /d "%~dp0..\backend\cmd\server"
go build -trimpath -o "%~dp0..\..\build\qq-pet-server.exe" .
echo Backend built.
