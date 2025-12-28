# PowerShell Script: Build React App and Prepare Files for Quick Update
# This builds only the React app and prepares files to copy into existing container

Write-Host "=== Quick File Update Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if Node.js is installed
Write-Host "Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    $npmVersion = npm --version
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
    Write-Host "npm: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Node.js/npm is not installed!" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Red
    exit 1
}

Write-Host ""

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $SCRIPT_DIR

# Step 1: Install dependencies (if needed)
Write-Host "Step 1: Checking dependencies..." -ForegroundColor Yellow
if (-not (Test-Path "node_modules")) {
    Write-Host "Installing dependencies (first time only)..." -ForegroundColor Gray
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install dependencies!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Dependencies already installed" -ForegroundColor Green
}

Write-Host ""

# Step 2: Build React app
Write-Host "Step 2: Building React app..." -ForegroundColor Yellow
Write-Host "This may take a minute..." -ForegroundColor Gray
Write-Host ""

npm run build

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build completed successfully!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 3: Verify dist folder exists
if (Test-Path "dist") {
    $distSize = (Get-ChildItem -Path "dist" -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "Build output created in 'dist' folder" -ForegroundColor Green
    Write-Host "Total size: $([math]::Round($distSize, 2)) MB" -ForegroundColor Gray
    
    Write-Host ""
    Write-Host "=== Build Complete ===" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Copy the entire 'dist' folder to your USB drive" -ForegroundColor White
    Write-Host "2. On the server, use the update commands from UPDATE_FILES_GUIDE.md" -ForegroundColor White
    Write-Host ""
    Write-Host "Folder location: $(Resolve-Path 'dist')" -ForegroundColor Gray
} else {
    Write-Host "ERROR: dist folder was not created!" -ForegroundColor Red
    exit 1
}




