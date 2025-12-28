#!/bin/bash

# Quick Deployment Script for USB Transfer Method
# This script loads the Docker image and deploys it
# Place this on your USB drive along with tic-tac-toe-latest.tar

set -e

echo "=== Tic-Tac-Toe USB Deployment ==="
echo ""

# Configuration
TAR_FILE="tic-tac-toe-latest.tar"
IMAGE_NAME="tic-tac-toe"
IMAGE_TAG="latest"
CONTAINER_NAME="tic-tac-toe"
PORT="80"

# Check if tar file exists
if [ ! -f "$TAR_FILE" ]; then
    echo "ERROR: $TAR_FILE not found in current directory!"
    echo "Please ensure the tar file is in the same directory as this script."
    exit 1
fi

echo "Found: $TAR_FILE"
FILE_SIZE=$(du -h "$TAR_FILE" | cut -f1)
echo "Size: $FILE_SIZE"
echo ""

# Load Docker image
echo "Step 1: Loading Docker image..."
docker load -i "$TAR_FILE"

if [ $? -eq 0 ]; then
    echo "✓ Image loaded successfully"
else
    echo "✗ Failed to load image"
    exit 1
fi

echo ""

# Stop and remove old container if it exists
echo "Step 2: Stopping old container (if exists)..."
if docker ps -a | grep -q "$CONTAINER_NAME"; then
    docker stop "$CONTAINER_NAME" 2>/dev/null || true
    docker rm "$CONTAINER_NAME" 2>/dev/null || true
    echo "✓ Old container removed"
else
    echo "✓ No old container found"
fi

echo ""

# Deploy new container
echo "Step 3: Deploying new container..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "${PORT}:80" \
  --restart unless-stopped \
  "${IMAGE_NAME}:${IMAGE_TAG}"

if [ $? -eq 0 ]; then
    echo "✓ Container deployed successfully"
else
    echo "✗ Failed to deploy container"
    exit 1
fi

echo ""

# Verify deployment
echo "Step 4: Verifying deployment..."
sleep 2

if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "✓ Container is running"
    echo ""
    echo "=== Deployment Complete ==="
    echo ""
    echo "Container Information:"
    docker ps | grep "$CONTAINER_NAME"
    echo ""
    echo "To view logs: docker logs -f $CONTAINER_NAME"
    echo "To stop: docker stop $CONTAINER_NAME"
    echo "To restart: docker restart $CONTAINER_NAME"
else
    echo "✗ Container failed to start"
    echo "Checking logs..."
    docker logs "$CONTAINER_NAME"
    exit 1
fi




