# 🎮 CyberPoker Server

Linux dedicated server deployment for CyberPoker multiplayer poker game.

## 🚀 Quick Start

### Automated Deployment (Recommended)

This repository uses GitHub Actions with SSH to automatically deploy to your server.

**Setup once (5 minutes):**
1. Generate SSH key pair
2. Add public key to your server
3. Create fine-grained GitHub token (repository-scoped)
4. Store token on server in `~/.github_token`
5. Add SSH secrets to GitHub (SSH_PRIVATE_KEY, SERVER_IP)

**Then just push to `main`:**
```bash
git push origin main
# Server automatically rebuilds and restarts via SSH!
```

See [Deployment Quick Start](docs/DEPLOYMENT_QUICK_START.md) for detailed setup.

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

### Server Won't Start

```bash
# Check logs
docker logs cyberpoker-server

# Check dependencies
docker exec cyberpoker-server ldd /app/Server.x86_64

# Rebuild from scratch
docker-compose -f docker/docker-compose.yml down
docker-compose -f docker/docker-compose.yml build --no-cache
docker-compose -f docker/docker-compose.yml up -d
```

### Can't Connect to Server

```bash
# Check firewall
sudo ufw status
sudo ufw allow 7770/tcp
sudo ufw allow 7770/udp

# Check port is listening
sudo netstat -tlnp | grep 7770

# Check Docker networking
docker network inspect bridge
```

### Deployment Fails

1. Check GitHub Actions logs: **Actions** tab → Latest run
2. Verify SSH connection:
   ```bash
   ssh ubuntu@YOUR_SERVER_IP "echo 'Connection test'"
   ```
3. Check GitHub secrets are set correctly
4. View server logs:
   ```bash
   ssh ubuntu@YOUR_SERVER_IP "docker logs cyberpoker-server"
   ```

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
