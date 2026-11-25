@echo off
setlocal
cd /d "%~dp0"

where typst >nul 2>&1
if %errorlevel%==0 (
  typst compile main.typ main.pdf
) else if exist "..\thesis\typst\typst.exe" (
  "..\thesis\typst\typst.exe" compile main.typ main.pdf
) else (
  echo Typst wurde nicht gefunden. Bitte Typst installieren oder typst.exe in diesen Ordner legen.
  exit /b 1
)

if errorlevel 1 (
  echo Build fehlgeschlagen.
  exit /b 1
)

echo.
echo Fertig: %~dp0main.pdf
start "" "%~dp0main.pdf"
exit /b 0
