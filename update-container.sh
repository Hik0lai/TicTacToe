#!/bin/bash

# Quick Container Update Script
# Updates files in running Docker container without rebuilding image

set -e

CONTAINER_NAME="${1:-tic-tac-toe}"
DIST_PATH="$2"

if [ -z "$DIST_PATH" ]; then
    echo "Usage: $0 [container-name] <path-to-dist-folder>"
    echo "Example: $0 tic-tac-toe ~/temp-update/dist"
    echo ""
    echo "If container-name is omitted, 'tic-tac-toe' will be used"
    exit 1
fi

# Check if container exists
if ! docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo "ERROR: Container '$CONTAINER_NAME' not found!"
    echo "Available containers:"
    docker ps -a --format "{{.Names}}"
    exit 1
fi

# Check if container is running
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo "WARNING: Container '$CONTAINER_NAME' is not running!"
    read -p "Start it now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker start "$CONTAINER_NAME"
        sleep 2
    else
        exit 1
    fi
fi

# Check if dist path exists
if [ ! -d "$DIST_PATH" ]; then
    echo "ERROR: Directory '$DIST_PATH' does not exist!"
    exit 1
fi

echo "=== Container Update Script ==="
echo "Container: $CONTAINER_NAME"
echo "Source: $DIST_PATH"
echo ""

# Backup existing files
echo "Step 1: Creating backup..."
BACKUP_DIR="/usr/share/nginx/html.backup.$(date +%Y%m%d_%H%M%S)"
docker exec "$CONTAINER_NAME" cp -r /usr/share/nginx/html "$BACKUP_DIR" || {
    echo "Warning: Backup failed, continuing anyway..."
}
echo "✓ Backup created at: $BACKUP_DIR"

# Copy new files
echo ""
echo "Step 2: Copying new files..."
docker cp "$DIST_PATH"/. "$CONTAINER_NAME:/usr/share/nginx/html/"
echo "✓ Files copied"

# Set correct permissions (nginx needs read access)
echo ""
echo "Step 3: Setting permissions..."
docker exec "$CONTAINER_NAME" chown -R nginx:nginx /usr/share/nginx/html/ || {
    echo "Warning: Permission change failed (may not be needed)"
}

# Reload nginx
echo ""
echo "Step 4: Reloading nginx..."
docker exec "$CONTAINER_NAME" nginx -s reload
echo "✓ Nginx reloaded"

# Verify
echo ""
echo "Step 5: Verifying..."
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "✓ Container is running"
else
    echo "✗ Container is not running!"
    exit 1
fi

echo ""
echo "=== Update Complete ==="
echo ""
echo "Container: $CONTAINER_NAME"
echo "Backup location: $BACKUP_DIR"
echo ""
echo "To view logs: docker logs -f $CONTAINER_NAME"
echo "To rollback: docker exec $CONTAINER_NAME cp -r $BACKUP_DIR/. /usr/share/nginx/html/ && docker exec $CONTAINER_NAME nginx -s reload"




