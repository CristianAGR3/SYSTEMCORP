@echo off
setlocal EnableExtensions
title GIC CONTROL 360 - Generar hash de contrasena

cd /d "%~dp0"

echo.
echo Generador de hash seguro PBKDF2 SHA-256
echo El resultado se pega en USERS_JSON dentro de Cloudflare Pages.
echo.

set /p PASSWORD=Escribe la contrasena: 
if "%PASSWORD%"=="" (
  echo ERROR: La contrasena no puede estar vacia.
  pause
  exit /b 1
)

echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\hash-password.ps1" -Password "%PASSWORD%"
echo.
pause
