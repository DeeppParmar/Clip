# OpenShorts Backend Server Launcher (PowerShell)
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "Starting OpenShorts FastAPI Backend..." -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Cyan

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$env:Path = "$scriptDir\bin;$env:APPDATA\Python\Python313\Scripts;$env:Path"

python -m uvicorn app:app --host 0.0.0.0 --port 8000 --reload
