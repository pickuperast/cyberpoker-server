# GitHub Actions Deployment Setup

✅ **Status: Fully Operational** - All components tested and working!

This document explains how the automated deployment works.

## Overview

The deployment uses **GitHub Actions** running on `ubuntu-latest` that connects to your server via **SSH** to deploy the CyberPoker server.

**Current Status:**
- ✅ SSH authentication working
- ✅ Docker DNS configured
- ✅ Git LFS pulling correctly
- ✅ Automated builds successful
- ✅ Zero-downtime deployments

## Architecture

```
┌─────────────────┐         SSH          ┌──────────────────┐
│  GitHub Actions │ ─────────────────────>│   Your Server    │
│  (ubuntu-latest)│                       │                  │
│                 │  1. Clone/Pull Repo   │  Docker          │
│  - Checkout code│  2. Build Docker      │  - Build image   │
│  - Setup SSH    │  3. Restart services  │  - Run container │
│  - Deploy       │                       │                  │
└─────────────────┘                       └──────────────────┘
```

## Required Setup

### GitHub Secrets

Set these in: **Settings** → **Secrets and variables** → **Actions**

| Secret | Description | Example |
|--------|-------------|---------|
| `SSH_PRIVATE_KEY` | Private SSH key for server access | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `SERVER_IP` | Your server's IP address | `123.45.67.89` |

### Server Token File

The GitHub token is stored on the server (not in GitHub Secrets) for better security:

- **Location**: `~/.github_token` on your server
- **Type**: Fine-grained personal access token
- **Scope**: Repository-specific, read-only access to Contents
- **Permissions**: File must be `600` (owner read/write only)

## How It Works

### Trigger
- Automatic: Push to `main` branch (only if `server/**`, `docker/**`, or workflow files change)
- Manual: Click "Run workflow" in Actions tab

### Steps

1. **Checkout code** - Gets latest code from repo including LFS files
2. **Setup SSH** - Installs SSH key and adds server to known_hosts
3. **Test connection** - Verifies SSH works
4. **Deploy** - SSHs into server and runs deployment script that:
   - Pulls latest code (or clones if first time)
   - Handles Git LFS files
   - Stops existing Docker containers
   - Builds new Docker image
   - Starts containers with new build
   - Verifies deployment

### Deployment Script Behavior

**If repo exists on server:**
- Stashes any local changes
- Pulls latest from GitHub
- Rebuilds and restarts

**If repo doesn't exist:**
- Clones entire repository
- Sets up directory structure
- Builds and starts for first time

## Customization

### Change Server Username

Edit `.github/workflows/deploy.yml`:

```yaml
env:
  SERVER_USER: "your-username"  # Change from "ubuntu"
```

### Change Deploy Directory

Edit `.github/workflows/deploy.yml`:

```yaml
env:
  PROJECT_DIR_ON_SERVER: "/your/custom/path"
```

### Change Docker Compose Location

Edit `.github/workflows/deploy.yml`:

```yaml
env:
  DOCKER_COMPOSE_PATH: "path/to/docker-compose.yml"
```

## Security

- SSH private key is stored encrypted in GitHub Secrets
- Key is only used during deployment
- Connection uses SSH key authentication (no passwords)
- Server needs public key in `~/.ssh/authorized_keys`
- GitHub token is stored on the server (not in GitHub Secrets)
- Token is fine-grained with repository-specific, read-only access
- Token file has restrictive permissions (600) for owner-only access

## Troubleshooting

### "Permission denied (publickey)"

1. Check public key is on server:
   ```bash
   ssh your-user@your-server "cat ~/.ssh/authorized_keys"
   ```

2. Verify private key in GitHub Secrets matches public key

3. Test SSH locally:
   ```bash
   ssh -i ~/.ssh/your_key user@server-ip "echo test"
   ```

### "docker: command not found"

Install Docker on your server:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### LFS files not pulling

Install Git LFS on server:
```bash
sudo apt-get install git-lfs
git lfs install
```

### Container fails to start

Check logs in GitHub Actions or SSH to server:
```bash
docker logs cyberpoker-server
```

## Manual Deployment

If GitHub Actions is unavailable, deploy manually:

```bash
ssh user@your-server
cd /opt/cyberpoker-server
git pull origin main
git lfs pull
docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml up -d --build
```

Or use the deploy script:
```bash
sudo ./scripts/deploy.sh
```

## Monitoring Deployments

1. **GitHub Actions**: Check Actions tab for deployment status
2. **Server logs**: `docker logs -f cyberpoker-server`
3. **Container status**: `docker ps | grep cyberpoker`

## Best Practices

1. **Test locally first** - Always test Docker build locally before pushing
2. **Use staging** - Consider a staging branch for testing
3. **Monitor logs** - Check deployment logs for errors
4. **Keep secrets secure** - Never commit secrets to repo
5. **Backup before major changes** - Have a rollback plan

---

**Last Updated:** 2025-10-11
