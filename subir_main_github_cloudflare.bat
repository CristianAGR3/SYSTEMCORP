@echo off
setlocal EnableExtensions
title GIC CONTROL 360 - Subir main a GitHub y Cloudflare

set "REPO_URL=https://github.com/CristianAGR3/SYSTEMCORP.git"
set "BRANCH=main"
set "PROJECT_NAME=systemcorp"

cd /d "%~dp0"

echo.
echo ============================================================
echo   GIC CONTROL 360 - PUBLICAR CAMBIOS
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
  echo Inicializando repositorio Git...
  git init
  if errorlevel 1 goto error
)

git branch -M %BRANCH%
if errorlevel 1 goto error

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  echo Agregando remoto origin...
  git remote add origin %REPO_URL%
) else (
  echo Actualizando remoto origin...
  git remote set-url origin %REPO_URL%
)
if errorlevel 1 goto error

echo.
echo Archivos modificados:
git status --short

echo.
set /p COMMIT_MSG=Mensaje del commit [Actualizar GIC Control 360]: 
if "%COMMIT_MSG%"=="" set "COMMIT_MSG=Actualizar GIC Control 360"

git add .
if errorlevel 1 goto error

git diff --cached --quiet
if errorlevel 1 (
  git commit -m "%COMMIT_MSG%"
  if errorlevel 1 goto error
) else (
  echo No hay cambios nuevos para commit.
)

echo.
echo Subiendo a GitHub: %REPO_URL% [%BRANCH%]
git push -u origin %BRANCH%
if errorlevel 1 goto error

echo.
echo GitHub quedo actualizado.
echo Si Cloudflare Pages esta conectado al repo, el despliegue se dispara automaticamente.
echo.

where npx >nul 2>nul
if errorlevel 1 (
  echo Wrangler opcional no disponible: instala Node.js si quieres deploy directo desde esta PC.
  goto done
)

echo Deseas ejecutar deploy directo con Cloudflare Wrangler tambien?
choice /C SN /N /M "S/N: "
if errorlevel 2 goto done

echo.
echo Ejecutando Cloudflare Pages deploy...
npx wrangler pages deploy . --project-name %PROJECT_NAME% --branch %BRANCH%
if errorlevel 1 (
  echo.
  echo No se pudo desplegar con Wrangler.
  echo Revisa que hayas iniciado sesion con: npx wrangler login
  echo O configura CLOUDFLARE_API_TOKEN en esta PC.
  pause
  exit /b 1
)

:done
echo.
echo Listo. Proyecto publicado.
pause
exit /b 0

:error
echo.
echo ERROR: El proceso se detuvo. Revisa el mensaje anterior.
pause
exit /b 1
