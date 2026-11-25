@echo off
setlocal
title Instalar BaronyVR (zeedif dev)
set "SRC=%~dp0BaronyVR\Managed"
set "DST=%LOCALAPPDATA%\BaronyVR\Managed"
if not exist "%DST%\Versions\BaronyVR-1.0.2\payload.json" (
  echo No se encontro BaronyVR 1.0.2 instalado en "%DST%".
  echo Instala primero BaronyVR 1.0.2 desde https://github.com/Nyxaroth37/BaronyVR/releases
  pause
  exit /b 1
)
tasklist /fi "imagename eq barony.exe" | find /i "barony.exe" >nul && (
  echo Cierra Barony antes de instalar.
  pause
  exit /b 1
)
xcopy "%SRC%" "%DST%" /E /Y /I /Q >nul || (
  echo No se pudieron copiar los archivos.
  pause
  exit /b 1
)
echo.
echo Listo. Abre Barony VR con el acceso directo de siempre.
pause
