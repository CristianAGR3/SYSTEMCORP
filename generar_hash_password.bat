@echo off
setlocal EnableExtensions
title GIC CONTROL 360 - Generar hash de contrasena

cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo ERROR: Node.js no esta instalado en esta PC.
  echo Descarga Node.js desde: https://nodejs.org/
  pause
  exit /b 1
)

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
node scripts\hash-password.mjs "%PASSWORD%"
echo.
pause
