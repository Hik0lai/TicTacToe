#!/bin/bash

# Bash Script: Deploy Tic-Tac-Toe Container on Server
# Run this on your Proxmox/Docker server to deploy the new version

set -e  # Exit on error

echo "=== Tic-Tac-Toe Deployment Script ==="
echo ""

# Configuration
IMAGE_NAME="tic-tac-toe"
IMAGE_TAG="latest"
CONTAINER_NAME="tic-tac-toe"
PORT="80"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${CYAN}$1${NC}"
}

print_success() {
    echo -e "${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}$1${NC}"
}

print_error() {
    echo -e "${RED}$1${NC}"
}

# Check if Docker is installed
print_info "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    print_error "ERROR: Docker is not installed!"
    exit 1
fi
print_success "Docker is installed"

echo ""

# Check if image exists
FULL_IMAGE_NAME="${IMAGE_NAME}:${IMAGE_TAG}"
if ! docker images | grep -q "${IMAGE_NAME}.*${IMAGE_TAG}"; then
    print_error "ERROR: Docker image ${FULL_IMAGE_NAME} not found!"
    echo ""
    echo "Please either:"
    echo "  1. Load the image: docker load -i tic-tac-toe-latest.tar"
    echo "  2. Build the image: docker build -t ${FULL_IMAGE_NAME} ."
    exit 1
fi
print_success "Docker image ${FULL_IMAGE_NAME} found"

echo ""

# Check if old container exists and stop it
if docker ps -a | grep -q "${CONTAINER_NAME}"; then
    print_warning "Found existing container: ${CONTAINER_NAME}"
    
    # Check if container is running
    if docker ps | grep -q "${CONTAINER_NAME}"; then
        print_info "Stopping existing container..."
        docker stop "${CONTAINER_NAME}"
        print_success "Container stopped"
    fi
    
    print_info "Removing old container..."
    docker rm "${CONTAINER_NAME}"
    print_success "Old container removed"
else
    print_info "No existing container found"
fi

echo ""

# Check if port is available
print_info "Checking if port ${PORT} is available..."
if netstat -tuln 2>/dev/null | grep -q ":${PORT} " || ss -tuln 2>/dev/null | grep -q ":${PORT} "; then
    print_warning "Port ${PORT} appears to be in use!"
    echo "This might be from another container. Proceeding anyway..."
else
    print_success "Port ${PORT} is available"
fi

echo ""

# Deploy new container
print_info "Deploying new container..."
print_info "  Image: ${FULL_IMAGE_NAME}"
print_info "  Container Name: ${CONTAINER_NAME}"
print_info "  Port: ${PORT}:80"
echo ""

docker run -d \
  --name "${CONTAINER_NAME}" \
  -p "${PORT}:80" \
  --restart unless-stopped \
  "${FULL_IMAGE_NAME}"

if [ $? -eq 0 ]; then
    print_success "Container deployed successfully!"
else
    print_error "ERROR: Failed to deploy container!"
    exit 1
fi

echo ""

# Verify container is running
print_info "Verifying container status..."
sleep 2

if docker ps | grep -q "${CONTAINER_NAME}"; then
    print_success "Container is running!"
    
    # Show container info
    echo ""
    print_info "Container Information:"
    docker ps | grep "${CONTAINER_NAME}"
    
    # Show logs
    echo ""
    print_info "Recent container logs:"
    docker logs --tail 10 "${CONTAINER_NAME}"
    
    echo ""
    print_success "=== Deployment Complete ==="
    echo ""
    print_info "Container is running at: http://$(hostname -I | awk '{print $1}'):${PORT}"
    print_info "Or access via your configured domain/IP"
    echo ""
    print_info "Useful commands:"
    echo "  View logs:    docker logs -f ${CONTAINER_NAME}"
    echo "  Stop:         docker stop ${CONTAINER_NAME}"
    echo "  Start:        docker start ${CONTAINER_NAME}"
    echo "  Restart:      docker restart ${CONTAINER_NAME}"
    echo "  Remove:       docker rm -f ${CONTAINER_NAME}"
else
    print_error "ERROR: Container failed to start!"
    print_info "Checking logs..."
    docker logs "${CONTAINER_NAME}"
    exit 1
fi




