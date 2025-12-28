# Deployment Guide: Tic-Tac-Toe Game Update

This guide will help you replace the old version of the game with the new responsive version on your Proxmox/Docker/Nginx setup.

## Architecture Overview
- **Proxmox** (on Intel NUC, accessed remotely)
  - **Docker** (running inside Proxmox)
    - **Nginx Container** (serving the React app)

## Prerequisites
- Remote access to your Proxmox server
- Docker installed and running on the Proxmox VM/Container
- Access to the directory where your current game container is running
- SSH access or console access to the Docker host

---

## Deployment Methods

### Method 1: Build Locally and Transfer (Recommended for Windows)

#### Step 1: Build the Docker Image Locally

On your local Windows machine, navigate to the project directory and build the image:

```powershell
# Navigate to project directory
cd "C:\Users\user\Documents\ReactCourseUdemy\react-complete-guide-course-resources-main\attachments\03 React Essentials\07-tic-tac-toe-starting-project\07-tic-tac-toe-starting-project"

# Build the Docker image
docker build -t tic-tac-toe:latest .
```

#### Step 2: Save Docker Image to File

```powershell
# Save the image to a tar file
docker save -o tic-tac-toe-latest.tar tic-tac-toe:latest
```

#### Step 3: Transfer Image to Proxmox Server

Transfer the tar file to your Proxmox server using one of these methods:

**Option A: Using SCP (if you have SSH access)**
```powershell
# From your local machine
scp tic-tac-toe-latest.tar user@proxmox-server:/path/to/destination/
```

**Option B: Using WinSCP or similar GUI tool**
- Connect to your Proxmox server
- Upload `tic-tac-toe-latest.tar` to a directory accessible from your Docker host

**Option C: Using Shared Storage or Network Drive**
- Copy the file to a network share accessible from Proxmox

#### Step 4: Load Image on Docker Host

SSH into your Proxmox server (or the Docker host), then:

```bash
# Load the Docker image
docker load -i /path/to/tic-tac-toe-latest.tar

# Verify the image is loaded
docker images | grep tic-tac-toe
```

#### Step 5: Deploy the New Container

```bash
# Find your current container name/ID
docker ps | grep tic-tac-toe

# Stop and remove the old container (replace CONTAINER_NAME with actual name)
docker stop CONTAINER_NAME
docker rm CONTAINER_NAME

# Run the new container (adjust port mapping and name as needed)
docker run -d \
  --name tic-tac-toe \
  -p 80:80 \
  --restart unless-stopped \
  tic-tac-toe:latest
```

---

### Method 2: Build Directly on Server (Recommended if you have Git access)

#### Step 1: Transfer Code to Server

Transfer the entire project directory to your Proxmox server:

```powershell
# Using SCP (from your local machine)
scp -r "C:\Users\user\Documents\ReactCourseUdemy\react-complete-guide-course-resources-main\attachments\03 React Essentials\07-tic-tac-toe-starting-project\07-tic-tac-toe-starting-project" user@proxmox-server:/path/to/projects/

# Or use WinSCP/FileZilla to upload the folder
```

#### Step 2: Build and Deploy on Server

SSH into your server and:

```bash
# Navigate to project directory
cd /path/to/projects/07-tic-tac-toe-starting-project

# Build the Docker image
docker build -t tic-tac-toe:latest .

# Stop and remove old container
docker stop tic-tac-toe 2>/dev/null || true
docker rm tic-tac-toe 2>/dev/null || true

# Run new container
docker run -d \
  --name tic-tac-toe \
  -p 80:80 \
  --restart unless-stopped \
  tic-tac-toe:latest
```

---

### Method 3: Using Docker Compose (If you want to set it up)

If you prefer using docker-compose for easier management, see the `docker-compose.yml` file (will be created if needed).

---

## Verification Steps

1. **Check Container Status**
   ```bash
   docker ps | grep tic-tac-toe
   ```

2. **Check Container Logs**
   ```bash
   docker logs tic-tac-toe
   ```

3. **Test the Application**
   - Open your browser and navigate to: `http://your-server-ip`
   - Test the responsive design by resizing your browser window
   - Test on mobile device if possible

4. **Verify Responsive Features**
   - Resize browser to mobile size - players should stack vertically
   - Game board buttons should scale appropriately
   - Text should remain readable at all sizes

---

## Troubleshooting

### Container Won't Start
```bash
# Check logs for errors
docker logs tic-tac-toe

# Check if port 80 is already in use
docker ps | grep ":80"
# Or
netstat -tulpn | grep :80
```

### Port Already in Use
If port 80 is already in use, either:
- Stop the conflicting container/service
- Or change the port mapping:
  ```bash
  docker run -d --name tic-tac-toe -p 8080:80 tic-tac-toe:latest
  ```
  Then access via `http://your-server-ip:8080`

### Image Won't Load
```bash
# Verify the tar file isn't corrupted
docker load -i tic-tac-toe-latest.tar

# If it fails, rebuild on the server directly
```

### Old Version Still Showing
```bash
# Force remove old container and images
docker stop tic-tac-toe
docker rm -f tic-tac-toe
docker rmi old-image-name

# Pull/load new image again
docker load -i tic-tac-toe-latest.tar

# Run new container
docker run -d --name tic-tac-toe -p 80:80 --restart unless-stopped tic-tac-toe:latest
```

---

## Rollback Plan

If you need to rollback to the old version:

```bash
# Stop current container
docker stop tic-tac-toe

# Tag and run old image (if you saved it)
docker tag old-image-name tic-tac-toe:old
docker run -d --name tic-tac-toe -p 80:80 tic-tac-toe:old
```

---

## Additional Notes

- **Container Name**: Adjust `tic-tac-toe` to match your actual container name
- **Port Mapping**: Adjust `-p 80:80` if your setup uses different ports
- **Network Mode**: If your container is on a custom Docker network, add `--network your-network-name`
- **Volume Mounts**: If you had volumes mounted, preserve them in the new container
- **Environment Variables**: Add any needed env vars with `-e KEY=value`

---

## Quick Reference Commands

```bash
# Build image
docker build -t tic-tac-toe:latest .

# List running containers
docker ps

# Stop container
docker stop tic-tac-toe

# Remove container
docker rm tic-tac-toe

# List images
docker images

# Remove old images
docker rmi old-image-name

# View logs
docker logs -f tic-tac-toe

# Execute command in container
docker exec -it tic-tac-toe sh
```




