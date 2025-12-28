# Quick File Update Guide - No Docker Rebuild Needed!

This method updates only the web files in your existing Docker container without rebuilding the entire image. **Much faster!**

---

## Overview

Instead of rebuilding the Docker image (~500MB-1GB), we just:
1. Build the React app locally (creates `dist` folder ~1-5MB)
2. Copy `dist` folder to server
3. Replace files in running container
4. Reload nginx

**Time saved:** 5-10 minutes → 1-2 minutes!

---

## Step 1: Build React App on Windows

### Using the Script (Easiest)

1. **Open PowerShell** in your project directory
2. **Run the build script**:
   ```powershell
   .\update-files-only.ps1
   ```

### Manual Build

1. **Open PowerShell** in your project directory
2. **Build the app**:
   ```powershell
   npm run build
   ```

This creates/updates the `dist` folder with your compiled React app.

---

## Step 2: Copy to USB Drive

1. **Copy the entire `dist` folder** to your USB drive
   - The folder should contain: `index.html`, `assets/`, and image files
   - Size: ~1-5MB (much smaller than Docker image!)

---

## Step 3: Update Running Container on Server

### Option A: Using docker cp (Recommended)

1. **Plug USB into server** and mount (if needed)
2. **Copy files from USB to server**:
   ```bash
   # Mount USB (if needed)
   sudo mkdir -p /mnt/usb
   sudo mount /dev/sdb1 /mnt/usb
   
   # Create temp directory
   mkdir -p ~/temp-update
   cp -r /mnt/usb/dist ~/temp-update/
   ```

3. **Find your container name**:
   ```bash
   docker ps | grep tic-tac-toe
   ```
   (Note the container name, e.g., `tic-tac-toe`)

4. **Copy files into container** (replace `tic-tac-toe` with your container name):
   ```bash
   # Backup old files (optional but recommended)
   docker exec tic-tac-toe cp -r /usr/share/nginx/html /usr/share/nginx/html.backup
   
   # Copy new files into container
   docker cp ~/temp-update/dist/. tic-tac-toe:/usr/share/nginx/html/
   
   # Reload nginx to apply changes
   docker exec tic-tac-toe nginx -s reload
   ```

### Option B: Using docker exec (Interactive)

1. **Copy files to server** (same as Option A step 2)
2. **Execute shell in container**:
   ```bash
   docker exec -it tic-tac-toe sh
   ```
3. **Inside container, copy files**:
   ```bash
   # You're now inside the container
   # Exit with: exit
   ```
   (Not recommended - harder to manage files this way)

### Option C: Using Volume Mount (For Future Updates)

If you set up a volume mount, you can update files directly. But this requires container recreation, so Option A is simpler for now.

---

## Step 4: Verify Update

1. **Check container is still running**:
   ```bash
   docker ps | grep tic-tac-toe
   ```

2. **Check nginx status**:
   ```bash
   docker exec tic-tac-toe nginx -t
   ```

3. **View container logs**:
   ```bash
   docker logs tic-tac-toe
   ```

4. **Test in browser**:
   - Clear browser cache (Ctrl+Shift+Delete)
   - Visit `http://your-server-ip`
   - Verify new features are working

---

## Quick Reference Commands

### On Windows (Build):
```powershell
cd "path\to\project"
.\update-files-only.ps1
# Copy 'dist' folder to USB
```

### On Server (Update):
```bash
# Copy from USB
cp -r /mnt/usb/dist ~/temp-update/

# Update container
docker cp ~/temp-update/dist/. tic-tac-toe:/usr/share/nginx/html/

# Reload nginx
docker exec tic-tac-toe nginx -s reload

# Verify
docker ps | grep tic-tac-toe
```

---

## Automated Update Script

Create `update-container.sh` on your server:

```bash
#!/bin/bash
# Quick container update script

CONTAINER_NAME="tic-tac-toe"
DIST_PATH="$1"  # Pass dist folder path as argument

if [ -z "$DIST_PATH" ]; then
    echo "Usage: $0 <path-to-dist-folder>"
    echo "Example: $0 ~/temp-update/dist"
    exit 1
fi

echo "Updating container: $CONTAINER_NAME"
echo "Source: $DIST_PATH"
echo ""

# Backup
echo "Creating backup..."
docker exec $CONTAINER_NAME cp -r /usr/share/nginx/html /usr/share/nginx/html.backup

# Copy files
echo "Copying files..."
docker cp $DIST_PATH/. $CONTAINER_NAME:/usr/share/nginx/html/

# Reload nginx
echo "Reloading nginx..."
docker exec $CONTAINER_NAME nginx -s reload

echo ""
echo "Update complete!"
echo "Container is running at: http://$(hostname -I | awk '{print $1}')"
```

**Usage:**
```bash
chmod +x update-container.sh
./update-container.sh ~/temp-update/dist
```

---

## Troubleshooting

### Files not updating?
```bash
# Check if files were copied
docker exec tic-tac-toe ls -la /usr/share/nginx/html/

# Force reload
docker exec tic-tac-toe nginx -s reload

# Restart container if needed
docker restart tic-tac-toe
```

### Nginx reload failed?
```bash
# Check nginx config
docker exec tic-tac-toe nginx -t

# View nginx error log
docker exec tic-tac-toe cat /var/log/nginx/error.log
```

### Rollback to previous version
```bash
# Restore backup
docker exec tic-tac-toe cp -r /usr/share/nginx/html.backup/. /usr/share/nginx/html/
docker exec tic-tac-toe nginx -s reload
```

---

## Comparison: Full Rebuild vs File Update

| Method | Time | File Size | Complexity |
|--------|------|-----------|------------|
| **Full Docker Rebuild** | 5-10 min | 500MB-1GB | High |
| **File Update Only** | 1-2 min | 1-5MB | Low |

**Recommendation:** Use file update for quick fixes, use full rebuild for major changes or Docker config updates.

---

## Tips

1. **Always backup** before updating: The script includes a backup step
2. **Clear browser cache** when testing updates
3. **Check container logs** if something goes wrong
4. **Keep old `dist` folder** on USB as backup
5. **Test on local dev** before deploying: `npm run preview`

---

## When to Use Each Method

### Use File Update When:
- ✅ Updating React code/features
- ✅ Changing styles/CSS
- ✅ Quick bug fixes
- ✅ Frequent updates

### Use Full Rebuild When:
- ✅ Changing Docker configuration
- ✅ Updating nginx config
- ✅ Changing Node.js version
- ✅ Major infrastructure changes




