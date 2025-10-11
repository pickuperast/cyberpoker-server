# 🚀 CyberPoker Server Deployment Quick Start

✅ **Status: Fully Operational** - All deployment workflows are tested and working!

## One-Time Setup (5 minutes)

### Step 1: Generate SSH Key Pair

On your **local machine**:

```bash
# Generate SSH key for deployments
ssh-keygen -t ed25519 -C "github-actions@cyberpoker" -f ~/.ssh/cyberpoker_deploy

# This creates:
# ~/.ssh/cyberpoker_deploy (private key - for GitHub)
# ~/.ssh/cyberpoker_deploy.pub (public key - for server)
```

### Step 2: Add Public Key to Server

```bash
# Copy the public key
cat ~/.ssh/cyberpoker_deploy.pub

# SSH into your server
ssh your-user@your-server.com

# Add the public key
mkdir -p ~/.ssh
echo "PASTE_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Step 3: Create GitHub Fine-Grained Token

1. Go to your repository on GitHub
2. Click your profile picture → **Settings** → **Developer settings** → **Personal access tokens** → **Fine-grained tokens**
3. Click **Generate new token**
4. Configure the token:
   - **Token name**: `cyberpoker-server-deploy`
   - **Expiration**: Choose appropriate duration (90 days recommended, can be renewed)
   - **Repository access**: Select **Only select repositories** → Choose `cyberpoker-server`
   - **Repository permissions**:
     - **Contents**: Read-only (required for cloning)
     - **Metadata**: Read-only (automatically selected)
5. Click **Generate token**
6. **Copy the token immediately** (you won't see it again!)

### Step 4: Store Token on Server

```bash
# SSH into your server
ssh your-user@your-server.com

# Create token file with secure permissions
echo "github_pat_YOUR_TOKEN_HERE" > ~/.github_token
chmod 600 ~/.github_token

# Verify it's saved correctly
cat ~/.github_token
```

**Important:** Replace `github_pat_YOUR_TOKEN_HERE` with your actual token.

### Step 5: Add Secrets to GitHub Actions

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret** and add these:

| Secret Name | Value | How to Get |
|-------------|-------|------------|
| `SSH_PRIVATE_KEY` | Your private key | `cat ~/.ssh/cyberpoker_deploy` |
| `SERVER_IP` | Your server IP | `123.45.67.89` |

**Important:** Copy the **entire** private key including the `-----BEGIN` and `-----END` lines.

### Step 6: Update Workflow Config (if needed)

If your server username is **not** `ubuntu`, update `.github/workflows/deploy.yml`:

```yaml
env:
  SERVER_USER: "your-username"  # Change this
```

### Step 7: Test Deployment ✅

The deployment system is fully configured and working!

```bash
# Make any change and push
git add .
git commit -m "build: Update server to v1.3.0"
git push origin main
```

Watch it deploy: **Actions** tab → Latest workflow run

**Expected behavior:**
- ✅ GitHub Actions triggers automatically
- ✅ SSH connection established to server
- ✅ Repository cloned/updated on server
- ✅ Docker image built successfully
- ✅ Container started and running
- ✅ Server accessible on port 7770

---

## Daily Usage

### Automatic Deployment (Recommended)

Just push to `main` and it auto-deploys:

```bash
git add .
git commit -m "build: Update server to v1.3.0"
git push origin main
```

Watch it deploy: **Actions** tab → Latest workflow run

### Manual Deployment

**Option 1:** GitHub Actions
- Go to **Actions** → **Deploy Server** → **Run workflow**

**Option 2:** SSH into server manually
```bash
ssh user@your-server.com
cd /opt/cyberpoker-server
sudo ./scripts/deploy.sh
```

---

## Monitoring

```bash
# Check server status
docker ps | grep cyberpoker

# View server logs
docker logs -f cyberpoker-server

# Check deployment history
cd /opt/cyberpoker-server && git log --oneline -5
```

---

## Troubleshooting

✅ **All systems operational!** Common issues and solutions:

| Problem | Solution | Status |
|---------|----------|--------|
| SSH connection fails | Check `SERVER_IP` and `SSH_PRIVATE_KEY` secrets | ✅ Working |
| Permission denied | `sudo usermod -aG docker ubuntu` on server | ✅ Configured |
| Deployment fails | Check Actions logs on GitHub | ✅ Working |
| Server won't start | `docker logs cyberpoker-server` | ✅ Running |
| LFS files not pulling | Install `git-lfs` on server: `sudo apt install git-lfs` | ✅ Installed |
| Docker DNS issues | Configured in `/etc/docker/daemon.json` | ✅ Fixed |

---

## Common Commands

```bash
# Restart server manually
cd /opt/cyberpoker-server
docker-compose -f docker/docker-compose.yml restart

# View live logs
docker logs -f cyberpoker-server

# Check server resources
docker stats cyberpoker-server

# Restart runner
sudo ~/actions-runner/svc.sh restart
```

---

## Required Setup

### GitHub Secrets

Make sure these are set in **Settings** → **Secrets and variables** → **Actions**:

- ✅ `SSH_PRIVATE_KEY` - Your private SSH key
- ✅ `SERVER_IP` - Your server's IP address

### Server Token File

Make sure this file exists on your server:

- ✅ `~/.github_token` - Fine-grained GitHub token (permissions: read-only Contents)
- File should have `600` permissions (readable only by you)

---

## Token & Key Management

### Regenerate SSH Key

```bash
# Generate new key
ssh-keygen -t ed25519 -C "github-actions@cyberpoker" -f ~/.ssh/cyberpoker_deploy_new

# Add new public key to server
ssh your-user@your-server.com
echo "NEW_PUBLIC_KEY" >> ~/.ssh/authorized_keys

# Update GitHub secret with new private key
# Settings → Secrets → SSH_PRIVATE_KEY → Update
```

### Regenerate GitHub Token

```bash
# On GitHub:
# 1. Settings → Developer settings → Personal access tokens → Fine-grained tokens
# 2. Find your token → Revoke
# 3. Generate new token (same settings as before)
# 4. Copy the new token

# On server:
ssh your-user@your-server.com
echo "github_pat_NEW_TOKEN_HERE" > ~/.github_token
chmod 600 ~/.github_token
```

### Test SSH Connection Locally

```bash
# Test connection with your key
ssh -i ~/.ssh/cyberpoker_deploy ubuntu@YOUR_SERVER_IP "echo 'Connection successful'"
```

### Verify Token on Server

```bash
# SSH into server
ssh your-user@your-server.com

# Check token file exists and has correct permissions
ls -la ~/.github_token
# Should show: -rw------- (600 permissions)

# Test token works (optional - only if repo is private)
TOKEN=$(cat ~/.github_token)
curl -H "Authorization: token $TOKEN" https://api.github.com/repos/YOUR-USERNAME/cyberpoker-server
```
