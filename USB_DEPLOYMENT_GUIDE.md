# USB Flash Drive Deployment Guide

This guide explains how to update your Tic-Tac-Toe game running on Nginx using a USB flash drive.

## Prerequisites
- Docker Desktop installed and running on your Windows PC
- USB flash drive (enough space for ~500MB-1GB Docker image)
- Access to your Proxmox server (SSH or console)

---

## Step 1: Build Docker Image on Windows

### Option A: Using the PowerShell Script (Easiest)

1. **Open PowerShell** in your project directory:
   ```powershell
   cd "C:\Users\user\Documents\ReactCourseUdemy\react-complete-guide-course-resources-main\attachments\03 React Essentials\07-tic-tac-toe-starting-project\07-tic-tac-toe-starting-project"
   ```

2. **Run the build script**:
   ```powershell
   .\deploy-build.ps1
   ```

3. This will create `tic-tac-toe-latest.tar` in your project folder.

### Option B: Manual Build

1. **Open PowerShell** in your project directory
2. **Build the Docker image**:
   ```powershell
   docker build -t tic-tac-toe:latest .
   ```
3. **Save the image to a tar file**:
   ```powershell
   docker save -o tic-tac-toe-latest.tar tic-tac-toe:latest
   ```

---

## Step 2: Copy to USB Flash Drive

1. **Insert your USB flash drive** into your Windows PC
2. **Copy the following files** to the USB drive:
   - `tic-tac-toe-latest.tar` (the Docker image)
   - `deploy-server.sh` (deployment script - optional but helpful)
   - `deploy-load.sh` (image loading script - optional)

**Note:** The tar file will be around 500MB-1GB in size, depending on your Docker image.

---

## Step 3: Transfer to Proxmox Server

1. **Safely eject** the USB drive from Windows
2. **Plug the USB drive** into your Proxmox server (or the machine running Docker)
3. **Mount the USB drive** (if not automatically mounted):
   ```bash
   # Find your USB drive (usually /dev/sdb1 or similar)
   lsblk
   
   # Create mount point and mount
   sudo mkdir -p /mnt/usb
   sudo mount /dev/sdb1 /mnt/usb  # Replace sdb1 with your actual device
   ```

4. **Copy files from USB to server**:
   ```bash
   # Create a directory for deployment files
   mkdir -p ~/tic-tac-toe-deploy
   
   # Copy files from USB
   cp /mnt/usb/tic-tac-toe-latest.tar ~/tic-tac-toe-deploy/
   cp /mnt/usb/deploy-load.sh ~/tic-tac-toe-deploy/  # If you copied it
   cp /mnt/usb/deploy-server.sh ~/tic-tac-toe-deploy/  # If you copied it
   
   # Make scripts executable
   chmod +x ~/tic-tac-toe-deploy/*.sh
   
   # Unmount USB (when done)
   sudo umount /mnt/usb
   ```

---

## Step 4: Deploy on Server

### Option A: Using Scripts (Recommended)

1. **Navigate to deployment directory**:
   ```bash
   cd ~/tic-tac-toe-deploy
   ```

2. **Load the Docker image**:
   ```bash
   ./deploy-load.sh
   ```
   Or manually:
   ```bash
   docker load -i tic-tac-toe-latest.tar
   ```

3. **Deploy the container**:
   ```bash
   ./deploy-server.sh
   ```

### Option B: Manual Deployment

1. **Load the Docker image**:
   ```bash
   cd ~/tic-tac-toe-deploy
   docker load -i tic-tac-toe-latest.tar
   ```

2. **Find your current container**:
   ```bash
   docker ps | grep tic-tac-toe
   ```
   Note the container name (e.g., `tic-tac-toe`)

3. **Stop and remove old container**:
   ```bash
   docker stop tic-tac-toe  # Replace with your container name
   docker rm tic-tac-toe
   ```

4. **Run new container**:
   ```bash
   docker run -d \
     --name tic-tac-toe \
     -p 80:80 \
     --restart unless-stopped \
     tic-tac-toe:latest
   ```

---

## Step 5: Verify Deployment

1. **Check container is running**:
   ```bash
   docker ps | grep tic-tac-toe
   ```

2. **Check container logs**:
   ```bash
   docker logs tic-tac-toe
   ```

3. **Test in browser**:
   - Open `http://your-server-ip` in your browser
   - Verify the new responsive design works
   - Test the win counter functionality

---

## Quick Reference Commands

### On Windows (Build):
```powershell
cd "path\to\project"
.\deploy-build.ps1
# Copy tic-tac-toe-latest.tar to USB
```

### On Server (Deploy):
```bash
# Load image
docker load -i /path/to/tic-tac-toe-latest.tar

# Stop old container
docker stop tic-tac-toe
docker rm tic-tac-toe

# Start new container
docker run -d --name tic-tac-toe -p 80:80 --restart unless-stopped tic-tac-toe:latest

# Verify
docker ps | grep tic-tac-toe
docker logs tic-tac-toe
```

---

## Troubleshooting

### Image won't load
```bash
# Check file exists and is not corrupted
ls -lh tic-tac-toe-latest.tar

# Try loading again
docker load -i tic-tac-toe-latest.tar
```

### Container won't start
```bash
# Check if port 80 is in use
sudo netstat -tulpn | grep :80
# Or
docker ps | grep ":80"

# Check logs for errors
docker logs tic-tac-toe
```

### Old version still showing
```bash
# Force remove everything
docker stop tic-tac-toe
docker rm -f tic-tac-toe
docker rmi tic-tac-toe:latest

# Load and deploy again
docker load -i tic-tac-toe-latest.tar
docker run -d --name tic-tac-toe -p 80:80 --restart unless-stopped tic-tac-toe:latest
```

---

## USB Drive Tips

1. **Format**: Use FAT32 or exFAT for compatibility (NTFS may need extra tools on Linux)
2. **File Size**: Docker images can be large - ensure your USB has enough space (1GB+ recommended)
3. **Safe Eject**: Always safely eject the USB drive to prevent corruption
4. **Backup**: Keep the tar file as backup in case you need to redeploy

---

## Alternative: Copy Entire Project (If USB is Large Enough)

If you prefer to build on the server:

1. Copy entire project folder to USB
2. On server, navigate to project folder
3. Build directly: `docker build -t tic-tac-toe:latest .`
4. Deploy: `./deploy-server.sh`

This avoids the large tar file but requires more USB space.




