# 🎮 CyberPoker Server

Linux dedicated server deployment for CyberPoker multiplayer poker game.

✅ **Status: Production Ready** - Automated deployment system is fully operational!

## 🚀 Quick Start

### Automated Deployment (Recommended)

This repository uses GitHub Actions with SSH to automatically deploy to your server.

**One-time setup (already completed):**
1. Generate SSH key pair
2. Add public key to your server
3. Create fine-grained GitHub token (repository-scoped)
4. Store token on server in `~/.github_token`
5. Add SSH secrets to GitHub (SSH_PRIVATE_KEY, SERVER_IP)

**Daily usage:**
```bash
git add .
git commit -m "build: Update server build"
git push origin main
# ✅ Server automatically rebuilds and restarts via SSH!
```

**What happens automatically:**
1. 🚀 GitHub Actions triggers on push to `main`
2. 🔐 SSH connection established to your server
3. 📥 Latest code pulled/cloned to `/opt/cyberpoker-server`
4. 🐳 Docker image built with new Unity build
5. ♻️ Container restarted with zero downtime
6. ✅ Server live on port 7770

See [Deployment Quick Start](docs/DEPLOYMENT_QUICK_START.md) for setup details.

### Manual Deployment

If you prefer manual deployment:

```bash
# SSH into your server
ssh user@your-server.com

# Run deploy script
cd /opt/cyberpoker-server
sudo ./scripts/deploy.sh
```

---

## 📁 Repository Structure

```
cyberpoker-server/
├── .github/workflows/     # GitHub Actions (auto-deployment)
├── server/                # Unity Linux build
├── docker/                # Docker configuration
├── scripts/               # Deployment scripts
├── docs/                  # Documentation
└── config/                # Server configuration
```

---

## 🐳 Docker Commands

```bash
# Start server
docker-compose -f docker/docker-compose.yml up -d

# Stop server
docker-compose -f docker/docker-compose.yml down

# View logs
docker logs -f cyberpoker-server

# Restart server
docker-compose -f docker/docker-compose.yml restart

# Rebuild
docker-compose -f docker/docker-compose.yml build
```

---

## 📊 Monitoring

```bash
# Check if running
docker ps | grep cyberpoker

# View logs
docker logs -f cyberpoker-server

# Check resources
docker stats cyberpoker-server

# Test connection
nc -zv your-server.com 7770
```

---

## 🔧 Configuration

Environment variables in `.env`:

```bash
SERVER_NAME=CyberPoker Server
SERVER_PORT=7770
MAX_PLAYERS=10
```

See `.env.example` for all available options.

---

## 📖 Documentation

- [Deployment Quick Start](docs/DEPLOYMENT_QUICK_START.md) - Setup and daily usage
- [Repository Conventions](CONVENTIONS.md) - Development standards

---

## 🛠️ Troubleshooting

✅ **System Status: All components operational**

### Quick Health Check

```bash
# Check if server is running
docker ps | grep cyberpoker

# View recent logs
docker logs cyberpoker-server --tail 50

# Test connection
nc -zv YOUR_SERVER_IP 7770
```

### Common Commands

```bash
# Restart server
docker-compose -f docker/docker-compose.yml restart

# View live logs
docker logs -f cyberpoker-server

# Check deployment history
cd /opt/cyberpoker-server && git log --oneline -5

# Manual deployment
ssh root@YOUR_SERVER_IP "cd /opt/cyberpoker-server && git pull && docker-compose -f docker/docker-compose.yml up -d --build"
```

### If Issues Occur

1. **Check GitHub Actions logs**: **Actions** tab → Latest workflow run
2. **View server logs**: `docker logs cyberpoker-server`
3. **Verify container status**: `docker ps | grep cyberpoker`
4. **Check firewall**: Ensure port 7770 (TCP/UDP) is open

---

## 🚨 Emergency Rollback

```bash
# View recent commits
cd /opt/cyberpoker-server
git log --oneline -5

# Rollback to previous version
git reset --hard <previous-commit-hash>
docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml up -d
```

---

## 📝 License

[Your License Here]

---

## 🤝 Contributing

See [CONVENTIONS.md](CONVENTIONS.md) for development guidelines.
