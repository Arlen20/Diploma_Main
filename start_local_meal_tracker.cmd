@echo off
setlocal

set "ROOT=%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%scripts\start_functions_emulator.ps1"
if errorlevel 1 exit /b %errorlevel%

cd /d "%ROOT%flutter_application_1"
flutter run -d chrome
