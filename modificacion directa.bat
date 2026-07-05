@echo off
setlocal EnableExtensions
title GIC CONTROL 360 - Modificacion directa

set "REPO_URL=https://github.com/CristianAGR3/SYSTEMCORP.git"
set "BRANCH=main"
set "PROJECT_NAME=systemcorp"
set "COMMIT_MSG=Modificacion directa GIC Control 360 %date% %time%"

cd /d "%~dp0"

echo.
echo ============================================================
echo   GIC CONTROL 360 - MODIFICACION DIRECTA
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
  echo Confirmando remoto origin...
  git remote set-url origin %REPO_URL%
)
if errorlevel 1 goto error

echo.
echo Preparando cambios locales...
git add .
if errorlevel 1 goto error

git diff --cached --quiet
if errorlevel 1 (
  echo Creando commit automatico...
  git commit -m "%COMMIT_MSG%"
  if errorlevel 1 goto error
) else (
  echo No hay cambios nuevos para commit.
)

echo.
echo Sincronizando con GitHub antes de subir...
git pull --rebase origin %BRANCH%
if errorlevel 1 (
  echo.
  echo ERROR: Git encontro conflictos al sincronizar.
  echo Resuelve los archivos marcados y ejecuta:
  echo   git rebase --continue
  echo   git push origin %BRANCH%
  pause
  exit /b 1
)

echo.
echo Subiendo cambios a GitHub...
git push -u origin %BRANCH%
if errorlevel 1 goto error

echo.
echo GitHub actualizado correctamente.
echo.

where npx >nul 2>nul
if errorlevel 1 (
  echo Cloudflare: no se encontro Node.js/npx en esta PC.
  echo Si Cloudflare Pages esta conectado a GitHub, el deploy se dispara automaticamente.
  goto done
)

echo Actualizando Cloudflare Pages directamente...
npx wrangler pages deploy . --project-name %PROJECT_NAME% --branch %BRANCH%
if errorlevel 1 (
  echo.
  echo GitHub ya quedo actualizado, pero Cloudflare Wrangler no pudo desplegar directo.
  echo Verifica sesion con:
  echo   npx wrangler login
  echo O revisa que Cloudflare Pages este conectado al repo para deploy automatico.
  goto done
)

echo.
echo Cloudflare Pages actualizado correctamente.

:done
echo.
echo Listo.
pause
exit /b 0

:error
echo.
echo ERROR: El proceso se detuvo. Revisa el mensaje anterior.
pause
exit /b 1
