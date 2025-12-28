#!/bin/bash

# Bash Script: Load Docker Image from Tar File and Deploy
# Use this if you transferred the image as a tar file

set -e

echo "=== Tic-Tac-Toe Image Loader ==="
echo ""

# Configuration
TAR_FILE="tic-tac-toe-latest.tar"
IMAGE_NAME="tic-tac-toe"
IMAGE_TAG="latest"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Check if tar file exists
if [ ! -f "$TAR_FILE" ]; then
    print_error "ERROR: File $TAR_FILE not found!"
    echo ""
    echo "Please ensure the tar file is in the current directory:"
    pwd
    exit 1
fi

print_success "Found tar file: $TAR_FILE"

# Get file size
FILE_SIZE=$(du -h "$TAR_FILE" | cut -f1)
print_info "File size: $FILE_SIZE"

echo ""

# Load the Docker image
print_info "Loading Docker image from $TAR_FILE..."
print_info "This may take a few minutes..."

docker load -i "$TAR_FILE"

if [ $? -eq 0 ]; then
    print_success "Image loaded successfully!"
    
    # Verify image exists
    echo ""
    print_info "Verifying image..."
    docker images | grep "${IMAGE_NAME}" | head -1
    
    echo ""
    print_success "=== Image Loaded ==="
    echo ""
    print_info "Next step: Run deploy-server.sh to deploy the container"
    echo "Or manually run:"
    echo "  docker run -d --name tic-tac-toe -p 80:80 --restart unless-stopped ${IMAGE_NAME}:${IMAGE_TAG}"
else
    print_error "ERROR: Failed to load image!"
    exit 1
fi




