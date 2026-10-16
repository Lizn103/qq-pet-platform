:: Build Vue frontend + embedded Go server -> build/qq-pet-frontend.exe (requires Node 20+ and Go)
@echo off
cd /d "%~dp0..\frontend"
npm ci || npm install
npx vite build
go build -trimpath -ldflags "-s -w" -o "%~dp0..\..\build\qq-pet-frontend.exe" .
echo Frontend built.
