@echo off
title OpenShorts Backend Server
echo ===================================================
echo Starting OpenShorts FastAPI Backend...
echo ===================================================

cd /d "%~dp0"

:: Ensure local bin (ffmpeg/ffprobe) is on PATH
set PATH=%~dp0bin;%APPDATA%\Python\Python313\Scripts;%PATH%

:: Start Uvicorn FastAPI Server
python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload

pause
