@echo off
setlocal EnableExtensions
title GIC CONTROL 360 - Modificacion directa

set "REPO_URL=https://github.com/CristianAGR3/SYSTEMCORP.git"
set "BRANCH=main"
set "COMMIT_MSG=Modificacion directa GIC Control 360 %date% %time%"

cd /d "%~dp0"

echo.
echo ============================================================
echo   GIC CONTROL 360 - MODIFICACION DIRECTA
echo ============================================================
echo.
echo Este publicador solo requiere Git.
echo Al subir a GitHub, Cloudflare Pages se actualiza automaticamente
echo si el proyecto esta conectado al repositorio.
echo.

where git >nul 2>nul
if errorlevel 1 (
  echo ERROR: Git no esta instalado en esta computadora.
  echo Instala Git desde:
  echo https://git-scm.com/download/win
  pause
  exit /b 1
)

if not exist ".git" (
  echo Inicializando repositorio Git...
  git init
  if errorlevel 1 goto error
)

echo Configurando rama y remoto...
git branch -M %BRANCH%
if errorlevel 1 goto error

git remote get-url origin >nul 2>nul
if errorlevel 1 (
  git remote add origin %REPO_URL%
) else (
  git remote set-url origin %REPO_URL%
)
if errorlevel 1 goto error

echo.
echo Estado actual:
git status --short

echo.
echo Preparando todos los cambios...
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
echo Trayendo cambios de GitHub y acomodando tus cambios encima...
git pull --rebase origin %BRANCH%
if errorlevel 1 (
  echo.
  echo ERROR: Git encontro conflictos al sincronizar.
  echo.
  echo Abre los archivos marcados, resuelve los conflictos y despues ejecuta:
  echo git add .
  echo git rebase --continue
  echo git push origin %BRANCH%
  echo.
  pause
  exit /b 1
)

echo.
echo Subiendo a GitHub...
git push -u origin %BRANCH%
if errorlevel 1 goto error

echo.
echo ============================================================
echo   LISTO
echo ============================================================
echo GitHub quedo actualizado.
echo Cloudflare Pages debe iniciar el deploy automatico desde GitHub.
echo No se requiere Node.js, npx ni Wrangler en esta computadora.
echo.
pause
exit /b 0

:error
echo.
echo ERROR: El proceso se detuvo. Revisa el mensaje anterior.
pause
exit /b 1
