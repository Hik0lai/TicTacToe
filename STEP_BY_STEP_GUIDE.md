# Step-by-Step Update Guide

## Prerequisites
- USB drive with `dist` folder plugged into Proxmox server
- Access to Proxmox console
- Access to Docker console (or can use same console)

---

## STEP 1: Mount USB Drive (Proxmox Console)

### 1.1 Find your USB device:
```bash
lsblk
```

Look for something like `sdb1` or `sdc1` (usually shows as USB device)

### 1.2 Create mount point:
```bash
sudo mkdir -p /mnt/usb
```

### 1.3 Mount the USB drive:
```bash
sudo mount /dev/sdb1 /mnt/usb
```
*(Replace `sdb1` with your actual USB device from step 1.1)*

### 1.4 Verify USB is mounted:
```bash
ls -la /mnt/usb
```

You should see your `dist` folder listed.

---

## STEP 2: Copy Files to Server (Proxmox Console)

### 2.1 Create temporary directory:
```bash
mkdir -p ~/temp-update
```

### 2.2 Copy dist folder from USB:
```bash
cp -r /mnt/usb/dist ~/temp-update/
```

### 2.3 Verify files copied:
```bash
ls -la ~/temp-update/dist
```

You should see files like `index.html`, `assets/` folder, etc.

---

## STEP 3: Find Container Name (Docker Console)

### 3.1 List running containers:
```bash
docker ps
```

Look for your container (probably named `tic-tac-toe` or similar). Note the exact name.

### 3.2 (Optional) List all containers (including stopped):
```bash
docker ps -a
```

---

## STEP 4: Update Container (Docker Console)

### 4.1 Make sure container is running:
```bash
docker ps | grep tic-tac-toe
```

If not running, start it:
```bash
docker start tic-tac-toe
```
*(Replace `tic-tac-toe` with your actual container name)*

### 4.2 Create backup (recommended):
```bash
docker exec tic-tac-toe cp -r /usr/share/nginx/html /usr/share/nginx/html.backup
```

### 4.3 Copy new files into container:
```bash
docker cp ~/temp-update/dist/. tic-tac-toe:/usr/share/nginx/html/
```
*(Replace `tic-tac-toe` with your actual container name)*

### 4.4 Verify files are in container:
```bash
docker exec tic-tac-toe ls -la /usr/share/nginx/html/
```

### 4.5 Reload nginx (apply changes):
```bash
docker exec tic-tac-toe nginx -s reload
```

---

## STEP 5: Verify Update (Docker Console)

### 5.1 Check container is still running:
```bash
docker ps | grep tic-tac-toe
```

### 5.2 Check nginx status:
```bash
docker exec tic-tac-toe nginx -t
```

Should show: `nginx: configuration file /etc/nginx/nginx.conf test is successful`

### 5.3 View container logs:
```bash
docker logs tic-tac-toe
```

Should show nginx reload message.

---

## STEP 6: Test in Browser

1. **Open your browser**
2. **Clear browser cache** (important!):
   - Chrome/Edge: `Ctrl + Shift + Delete` → Clear cached images and files
   - Firefox: `Ctrl + Shift + Delete` → Cached Web Content
3. **Visit**: `http://your-server-ip`
4. **Verify**:
   - Responsive design works
   - Win counters work
   - All new features are present

---

## STEP 7: Cleanup (Optional)

### 7.1 Unmount USB drive:
```bash
sudo umount /mnt/usb
```

### 7.2 Remove temporary files (optional):
```bash
rm -rf ~/temp-update
```

---

## Troubleshooting

### USB not showing up?
```bash
# Check all block devices
sudo fdisk -l

# Check dmesg for USB detection
dmesg | tail -20
```

### Container name different?
```bash
# Find all containers
docker ps -a

# Use the NAME column value in commands
```

### Files not updating?
```bash
# Check if files copied correctly
docker exec tic-tac-toe ls -la /usr/share/nginx/html/assets/

# Force nginx reload
docker exec tic-tac-toe nginx -s reload

# Or restart container
docker restart tic-tac-toe
```

### Need to rollback?
```bash
# Restore backup
docker exec tic-tac-toe cp -r /usr/share/nginx/html.backup/. /usr/share/nginx/html/
docker exec tic-tac-toe nginx -s reload
```

---

## Quick Command Summary

```bash
# Proxmox Console:
lsblk                                    # Find USB device
sudo mkdir -p /mnt/usb                   # Create mount point
sudo mount /dev/sdb1 /mnt/usb            # Mount USB (replace sdb1)
mkdir -p ~/temp-update                   # Create temp directory
cp -r /mnt/usb/dist ~/temp-update/       # Copy files

# Docker Console:
docker ps                                # Find container name
docker cp ~/temp-update/dist/. tic-tac-toe:/usr/share/nginx/html/  # Copy files
docker exec tic-tac-toe nginx -s reload  # Reload nginx
docker ps | grep tic-tac-toe             # Verify running
```

---

## Alternative: One-Console Method

If you can run Docker commands from Proxmox console, you can do everything in one session:

```bash
# Mount USB
sudo mkdir -p /mnt/usb
sudo mount /dev/sdb1 /mnt/usb

# Copy files
mkdir -p ~/temp-update
cp -r /mnt/usb/dist ~/temp-update/

# Update container (replace tic-tac-toe with your container name)
docker cp ~/temp-update/dist/. tic-tac-toe:/usr/share/nginx/html/
docker exec tic-tac-toe nginx -s reload

# Verify
docker ps | grep tic-tac-toe

# Unmount USB
sudo umount /mnt/usb
```




