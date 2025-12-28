# PowerShell Script: Build and Save Docker Image for Deployment
# Run this on your Windows machine to build and prepare the Docker image

Write-Host "=== Tic-Tac-Toe Deployment Script ===" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    docker --version | Out-Null
    Write-Host "Docker is installed and accessible" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Docker is not installed or not running!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop and ensure it's running." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Set variables
$IMAGE_NAME = "tic-tac-toe"
$IMAGE_TAG = "latest"
$TAR_FILE = "$IMAGE_NAME-$IMAGE_TAG.tar"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Build Configuration:" -ForegroundColor Cyan
Write-Host "  Image Name: $IMAGE_NAME" -ForegroundColor White
Write-Host "  Tag: $IMAGE_TAG" -ForegroundColor White
Write-Host "  Output File: $TAR_FILE" -ForegroundColor White
Write-Host "  Working Directory: $SCRIPT_DIR" -ForegroundColor White
Write-Host ""

# Change to script directory
Set-Location $SCRIPT_DIR

# Step 1: Build Docker image
Write-Host "Step 1: Building Docker image..." -ForegroundColor Yellow
Write-Host "This may take a few minutes on first build..." -ForegroundColor Gray
Write-Host ""

try {
    docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Docker image built successfully!" -ForegroundColor Green
    } else {
        Write-Host "ERROR: Docker build failed!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Failed to build Docker image: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 2: Save Docker image to tar file
Write-Host "Step 2: Saving Docker image to $TAR_FILE..." -ForegroundColor Yellow
Write-Host "This may take a minute..." -ForegroundColor Gray
Write-Host ""

# Remove old tar file if it exists
if (Test-Path $TAR_FILE) {
    Write-Host "Removing old $TAR_FILE..." -ForegroundColor Gray
    Remove-Item $TAR_FILE -Force
}

try {
    docker save -o $TAR_FILE "${IMAGE_NAME}:${IMAGE_TAG}"
    if ($LASTEXITCODE -eq 0) {
        $fileSize = (Get-Item $TAR_FILE).Length / 1MB
        Write-Host "Docker image saved successfully!" -ForegroundColor Green
        Write-Host "File size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor Gray
    } else {
        Write-Host "ERROR: Failed to save Docker image!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "ERROR: Failed to save Docker image: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Build Complete ===" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Transfer $TAR_FILE to your Proxmox server" -ForegroundColor White
Write-Host "2. Use SCP, WinSCP, or network share to copy the file" -ForegroundColor White
Write-Host "3. On the server, run: docker load -i $TAR_FILE" -ForegroundColor White
Write-Host "4. Deploy using the deployment commands in DEPLOYMENT_GUIDE.md" -ForegroundColor White
Write-Host ""
Write-Host "File location: $(Resolve-Path $TAR_FILE)" -ForegroundColor Gray




