# GitHub Self-Hosted Runner Setup Guide

This guide will help you set up a GitHub self-hosted runner on your CyberPoker server for automated deployments.

## 🎯 What This Does

- Runs GitHub Actions **directly on your server**
- No SSH keys or secrets needed
- Automatic deployment when you push to `main`
- Secure and simple

---

## 📋 Prerequisites

- Your Linux server with SSH access
- Docker and Docker Compose installed
- Git LFS installed
- Repository cloned to `/opt/cyberpoker-server`

---

## 🚀 Setup Instructions

### Step 1: SSH into Your Server

```bash
ssh your-user@your-server.com
```

### Step 2: Create Runner Directory

```bash
mkdir -p ~/actions-runner && cd ~/actions-runner
```

### Step 3: Download GitHub Actions Runner

```bash
# Download the latest runner (Linux x64)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

### Step 4: Get Registration Token from GitHub

1. Go to your repository on GitHub
2. Click **Settings** → **Actions** → **Runners**
3. Click **New self-hosted runner**
4. Select **Linux** as the OS
5. Copy the **token** from the configuration command

It will look like:
```
./config.sh --url https://github.com/YOUR-USERNAME/cyberpoker-server --token AAAAAA...
```

### Step 5: Configure the Runner

```bash
# Run the config script with your token
./config.sh --url https://github.com/YOUR-USERNAME/cyberpoker-server --token YOUR-TOKEN-HERE

# When prompted:
# - Runner name: Press Enter (uses hostname)
# - Runner group: Press Enter (uses default)
# - Labels: Press Enter (uses default)
# - Work folder: Press Enter (uses _work)
```

### Step 6: Install as a Service

```bash
# Install the service (requires sudo)
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

**Expected output:**
```
● actions.runner.YOUR-USERNAME-cyberpoker-server.YOUR-HOSTNAME.service - GitHub Actions Runner
   Loaded: loaded (/etc/systemd/system/actions.runner...service; enabled)
   Active: active (running)
```

### Step 7: Verify Runner is Connected

1. Go to your repository on GitHub
2. Click **Settings** → **Actions** → **Runners**
3. You should see your runner with a **green "Idle"** status

---

## ✅ Testing the Deployment

### Test Automatic Deployment

1. Make a small change to your repository (e.g., update README.md)
2. Commit and push to `main`:
   ```bash
   git add .
   git commit -m "test: Verify self-hosted runner deployment"
   git push origin main
   ```
3. Go to **Actions** tab on GitHub
4. Watch your workflow run on your self-hosted runner
5. Server should automatically rebuild and restart

### Manual Deployment Trigger

You can also trigger deployment manually:

1. Go to **Actions** tab on GitHub
2. Select **Deploy Server** workflow
3. Click **Run workflow** → **Run workflow**

---

## 🔧 Troubleshooting

### Runner Not Showing in GitHub

```bash
# Check if service is running
sudo ./svc.sh status

# View service logs
sudo journalctl -u actions.runner.* -f

# Restart service
sudo ./svc.sh stop
sudo ./svc.sh start
```

### Deployment Fails with Permission Error

The runner needs Docker permissions:

```bash
# Add runner user to docker group
sudo usermod -aG docker $(whoami)

# Restart runner service
sudo ~/actions-runner/svc.sh restart

# Verify
docker ps
```

### Repository Not Found Error

Make sure the repository is cloned to the correct location:

```bash
# Check if repo exists
ls -la /opt/cyberpoker-server

# If not, clone it
sudo mkdir -p /opt/cyberpoker-server
sudo git clone https://github.com/YOUR-USERNAME/cyberpoker-server.git /opt/cyberpoker-server

# Set permissions
sudo chown -R $(whoami):$(whoami) /opt/cyberpoker-server
```

### LFS Files Not Pulling

```bash
# Ensure Git LFS is installed
git lfs version

# If not installed:
sudo apt-get install git-lfs
git lfs install
```

---

## 🛠️ Runner Management

### View Runner Logs

```bash
# Real-time logs
sudo journalctl -u actions.runner.* -f

# Last 100 lines
sudo journalctl -u actions.runner.* -n 100
```

### Stop Runner

```bash
cd ~/actions-runner
sudo ./svc.sh stop
```

### Start Runner

```bash
cd ~/actions-runner
sudo ./svc.sh start
```

### Restart Runner

```bash
cd ~/actions-runner
sudo ./svc.sh restart
```

### Remove Runner

```bash
# Stop and uninstall service
cd ~/actions-runner
sudo ./svc.sh stop
sudo ./svc.sh uninstall

# Remove from GitHub (get removal token first)
# Go to Settings → Actions → Runners → Click your runner → Remove
./config.sh remove --token YOUR-REMOVAL-TOKEN
```

---

## 🔐 Security Notes

- Runner runs under your user account
- Has access to Docker and repository
- Only accepts jobs from your repository
- Secured by GitHub's authentication

### Best Practices:

1. **Dedicated User**: Create a dedicated `github-runner` user
   ```bash
   sudo useradd -m -s /bin/bash github-runner
   sudo usermod -aG docker github-runner
   # Then setup runner as that user
   ```

2. **Firewall**: Ensure only necessary ports are open
   ```bash
   sudo ufw status
   # Only 22 (SSH), 7770 (game), and 443 (HTTPS) needed
   ```

3. **Updates**: Keep runner updated
   ```bash
   cd ~/actions-runner
   sudo ./svc.sh stop
   # Download latest version and extract
   sudo ./svc.sh start
   ```

---

## 📊 Monitoring

### Check Deployment Status

```bash
# View running containers
docker ps

# View server logs
docker logs -f cyberpoker-server

# View last deployment
cd /opt/cyberpoker-server
git log -1
```

### Check Runner Status

```bash
# Service status
sudo systemctl status actions.runner.*

# Runner logs
sudo journalctl -u actions.runner.* --since today
```

---

## 🎉 You're Done!

Your server now has:
- ✅ Automated deployments on every push to `main`
- ✅ Manual deployment triggers from GitHub
- ✅ No SSH keys or secrets needed
- ✅ Deployment logs visible in GitHub Actions

### Next Steps:

1. Test a deployment by pushing a change
2. Monitor the Actions tab to see it run
3. Check server logs to verify everything works
4. Enjoy automated deployments! 🚀

---

## 📞 Need Help?

- Check GitHub Actions logs: Repository → Actions → Latest run
- Check server logs: `docker logs cyberpoker-server`
- Check runner logs: `sudo journalctl -u actions.runner.* -f`

---

**Last Updated:** 2025-10-11
