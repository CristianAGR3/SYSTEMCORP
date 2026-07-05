@echo off
setlocal EnableExtensions EnableDelayedExpansion
title GIC CONTROL 360 - Subir cambios de diseno a GitHub

set "REPO_URL=https://github.com/CristianAGR3/SYSTEMCORP.git"
set "BRANCH=main"
set "DEFAULT_MSG=Actualizar diseno de GIC Control 360"

cd /d "%~dp0"

echo.
echo ============================================================
echo   GIC CONTROL 360 - SUBIR CAMBIOS DE DISENO
echo ============================================================
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo ERROR: Git no esta instalado en esta PC.
  echo Descarga Git desde: https://git-scm.com/download/win
  pause
  exit /b 1
)

if not exist ".git" (
  echo ERROR: Esta carpeta no tiene repositorio Git.
  echo Ejecuta primero el publicador principal o clona el repo.
  pause
  exit /b 1
)

git branch -M %BRANCH%
if errorlevel 1 goto error

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  echo Agregando remoto origin...
  git remote add origin %REPO_URL%
) else (
  echo Confirmando remoto origin...
  git remote set-url origin %REPO_URL%
)
if errorlevel 1 goto error

echo.
echo Actualizando referencia de GitHub...
git fetch origin
if errorlevel 1 goto error

echo.
echo Cambios detectados:
git status --short

echo.
echo Se prepararan archivos de diseno si existen:
echo   index.html
echo   login.html
echo   css\
echo   js\
echo   assets\
echo   img\
echo   images\
echo.

if exist "index.html" git add index.html
if exist "login.html" git add login.html
if exist "css" git add css
if exist "js" git add js
if exist "assets" git add assets
if exist "img" git add img
if exist "images" git add images
if errorlevel 1 goto error

git diff --cached --quiet
if not errorlevel 1 (
  echo No hay cambios de diseno para subir.
  echo.
  pause
  exit /b 0
)

echo.
echo Archivos que se subiran:
git diff --cached --name-only

echo.
set /p COMMIT_MSG=Mensaje del commit [%DEFAULT_MSG%]: 
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=%DEFAULT_MSG%"

git commit -m "%COMMIT_MSG%"
if errorlevel 1 goto error

echo.
echo Integrando cambios nuevos de GitHub antes de subir...
git pull --rebase origin %BRANCH%
if errorlevel 1 (
  echo.
  echo No se pudo completar el rebase automaticamente.
  echo Revisa los conflictos, resuelvelos y luego ejecuta:
  echo   git rebase --continue
  echo   git push origin %BRANCH%
  pause
  exit /b 1
)

echo.
echo Subiendo a GitHub...
git push -u origin %BRANCH%
if errorlevel 1 goto error

echo.
echo Listo: cambios de diseno subidos a GitHub.
echo Si Cloudflare Pages esta conectado, se publicara automaticamente.
echo.
pause
exit /b 0

:error
echo.
echo ERROR: El proceso se detuvo. Revisa el mensaje anterior.
pause
exit /b 1
