# Quick Start Deployment Guide

## Fastest Method: Build and Deploy on Server

### Step 1: Build Docker Image on Your Windows Machine

Open PowerShell in the project directory and run:

```powershell
.\deploy-build.ps1
```

This will:
- Build the Docker image
- Save it as `tic-tac-toe-latest.tar`

### Step 2: Transfer to Server

Copy `tic-tac-toe-latest.tar` to your Proxmox server using:
- **WinSCP** (recommended for Windows)
- **SCP** command: `scp tic-tac-toe-latest.tar user@server:/path/`
- Network share/drive

### Step 3: Deploy on Server

SSH into your Proxmox/Docker server:

```bash
# Navigate to where you saved the tar file
cd /path/to/file/

# Make scripts executable (if transferring the whole project)
chmod +x deploy-load.sh deploy-server.sh

# Load the image
./deploy-load.sh

# Deploy the container
./deploy-server.sh
```

---

## Alternative: Build Directly on Server

If you have the project code on the server:

```bash
cd /path/to/project/

# Build the image
docker build -t tic-tac-toe:latest .

# Deploy using the script
./deploy-server.sh
```

---

## Using Docker Compose

If you prefer docker-compose:

```bash
# Build and start
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down

# Rebuild
docker-compose up -d --build
```

---

## Manual Commands (Quick Reference)

```bash
# Load image from tar file
docker load -i tic-tac-toe-latest.tar

# Stop and remove old container
docker stop tic-tac-toe
docker rm tic-tac-toe

# Run new container
docker run -d \
  --name tic-tac-toe \
  -p 80:80 \
  --restart unless-stopped \
  tic-tac-toe:latest

# Check status
docker ps | grep tic-tac-toe

# View logs
docker logs -f tic-tac-toe
```

---

## Verify Deployment

1. Check container is running: `docker ps | grep tic-tac-toe`
2. Check logs: `docker logs tic-tac-toe`
3. Visit: `http://your-server-ip`
4. Test responsive design by resizing browser window

---

## Troubleshooting

**Port already in use?**
```bash
# Find what's using port 80
docker ps | grep ":80"
# Or change port: -p 8080:80
```

**Container won't start?**
```bash
docker logs tic-tac-toe
```

**Need to rollback?**
```bash
docker stop tic-tac-toe
docker rm tic-tac-toe
docker run -d --name tic-tac-toe -p 80:80 old-image-name
```

---

For detailed instructions, see `DEPLOYMENT_GUIDE.md`




