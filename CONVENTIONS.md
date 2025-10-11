# CyberPoker Server - Repository Conventions

## 🎯 Repository Purpose

This repository serves as the **deployment pipeline** for CyberPoker's dedicated Linux server builds.

### What Lives Here

✅ **Included:**
- Unity Linux server builds (`.x86_64`, `.so` files, `Server_Data/`)
- Docker configuration for server containerization
- Deployment scripts and automation
- Server configuration files
- CI/CD workflows for auto-deployment

❌ **NOT Included:**
- Unity project source code (lives in `cyberpoker` repo)
- Client builds
- Game assets or source files
- Development tools

### Key Principles

1. **Build artifacts only** - This is a deployment repo, not a development repo
2. **Automation first** - Every deployment should be automated
3. **Immutable deployments** - Each commit represents a deployable state
4. **Environment parity** - Development, staging, and production use the same Docker setup

---

## 📁 Repository Structure

### Required Structure

```
cyberpoker-server/
├── .github/
│   └── workflows/
│       ├── deploy.yml              # Auto-deployment to production
│       ├── deploy-staging.yml      # Staging environment deployment
│       └── validate-build.yml      # Build validation checks
│
├── server/                         # Unity Linux build output
│   ├── Server_Data/                # Unity data folder
│   │   ├── Plugins/
│   │   ├── Resources/
│   │   ├── StreamingAssets/
│   │   ├── boot.config
│   │   ├── globalgamemanagers
│   │   └── ...
│   ├── FishNet.SDK.ld
│   ├── libdecor-0.so.0
│   ├── libdecor-cairo.so
│   ├── Server.x86_64               # Main server executable
│   └── UnityPlayer.so
│
├── docker/
│   ├── Dockerfile                  # Server container definition
│   ├── docker-compose.yml          # Production compose
│   ├── docker-compose.staging.yml  # Staging compose
│   └── .dockerignore
│
├── scripts/
│   ├── deploy.sh                   # Main deployment script
│   ├── start-server.sh             # Server startup script
│   ├── backup.sh                   # Backup script
│   ├── rollback.sh                 # Rollback to previous version
│   └── health-check.sh             # Server health monitoring
│
├── config/
│   ├── server-config.json          # Server configuration
│   └── network-config.json         # Network settings
│
├── logs/                           # Log directory (gitignored)
│
├── .env.example                    # Environment variables template
├── .env.staging.example            # Staging environment template
├── .gitattributes                  # Git LFS configuration
├── .gitignore
├── CONVENTIONS.md                  # This file
├── README.md                       # Repository documentation
└── CHANGELOG.md                    # Version history
```

### Directory Purposes

| Directory | Purpose | Modified By |
|-----------|---------|-------------|
| `server/` | Unity build artifacts | Automated from Unity |
| `docker/` | Container configuration | DevOps team |
| `scripts/` | Automation scripts | DevOps team |
| `config/` | Server settings | Game developers |
| `.github/workflows/` | CI/CD pipelines | DevOps team |

---

## 🌿 Branch Naming Conventions

### Branch Structure

```
<type>/<description>
```

### Types

| Type | Purpose | Example | Who Creates |
|------|---------|---------|-------------|
| `build/` | New Unity builds | `build/v1.2.0` | Automated/CI |
| `config/` | Configuration changes | `config/increase-max-players` | Developers |
| `docker/` | Docker changes | `docker/optimize-image-size` | DevOps |
| `fix/` | Bug fixes | `fix/server-crash-on-disconnect` | Developers |
| `hotfix/` | Production emergencies | `hotfix/memory-leak` | Developers |
| `chore/` | Maintenance | `chore/update-dependencies` | DevOps |

### Protected Branches

- **`main`** - Production deployments (requires PR + approval)
- **`staging`** - Staging environment (requires PR)
- **`develop`** - Integration branch (optional, if team > 5)

### Branch Lifecycle

```bash
# 1. Create feature branch
git checkout -b docker/add-health-checks

# 2. Make changes
git add .
git commit -m "Add Docker health checks for server monitoring"

# 3. Push and create PR
git push -u origin docker/add-health-checks

# 4. After merge, auto-delete branch
# GitHub setting: "Automatically delete head branches"
```

---

## 💬 Commit Message Guidelines

### Format

```
<type>: <description>

[optional body]

[optional footer]
```

### Types

| Type | When to Use | Example |
|------|-------------|---------|
| `build` | New Unity build uploaded | `build: Add server build v1.2.0` |
| `config` | Configuration changes | `config: Increase max players to 20` |
| `docker` | Docker/container changes | `docker: Optimize image size by 40%` |
| `fix` | Bug fixes | `fix: Resolve server crash on player disconnect` |
| `docs` | Documentation updates | `docs: Update deployment instructions` |
| `ci` | CI/CD changes | `ci: Add staging deployment workflow` |
| `chore` | Maintenance tasks | `chore: Update Git LFS tracking` |
| `revert` | Reverting changes | `revert: Revert "Add experimental feature"` |

### Examples

#### ✅ Good Commits

```bash
# Simple, clear
build: Add server build v1.2.0

# With body explaining why
config: Increase connection timeout to 30s

Players were experiencing disconnects during high latency.
Increased timeout from 10s to 30s based on telemetry data.

# With breaking change
docker: Update base image to Ubuntu 22.04

BREAKING CHANGE: Requires Docker Engine 20.10+
Older Docker versions may not support the new image format.

# Referencing issue
fix: Resolve memory leak in FishNet connection handler

Fixes #42
```

#### ❌ Bad Commits

```bash
# Too vague
update stuff

# No type prefix
Added new build

# Too much in one commit
build: Add v1.2.0, update Docker, fix config, refactor scripts

# Typos and unclear
fix: fixxed teh bug
```

### Commit Best Practices

1. **One logical change per commit**
2. **Present tense** - "Add feature" not "Added feature"
3. **Imperative mood** - "Fix bug" not "Fixes bug"
4. **Max 50 characters** for subject line
5. **Wrap body at 72 characters**
6. **Blank line between subject and body**

---

## 📦 File Organization Rules

### Unity Build Files

#### Naming Convention

```
server/Server.x86_64        ← Keep Unity's default naming
server/Server_Data/         ← Keep Unity's structure
```

**DO NOT** rename Unity build files. They have hardcoded dependencies.

#### When Updating Build

```bash
# 1. Remove old build (but keep Server_Data if only executable changed)
rm server/Server.x86_64
rm server/*.so

# 2. Copy new build from Unity
cp ~/Unity/Builds/LinuxServer/* server/

# 3. Ensure executable permissions
chmod +x server/Server.x86_64

# 4. Test locally with Docker
docker-compose -f docker/docker-compose.yml up

# 5. Commit
git add server/
git commit -m "build: Update server to v1.3.0"
```

### Git LFS Tracking

#### Files That MUST Use LFS

```bash
# Binary executables
*.x86_64
*.so
*.so.*

# Unity data files
Server_Data/**
*.dat
*.resource
*.assets
*.bundle
*.resS

# Large text files
*.json filter=lfs diff=lfs merge=lfs -text  # If > 1MB
```

#### Files That Should NOT Use LFS

```bash
# Configuration files
*.json   # (if < 1MB)
*.yml
*.yaml
*.env

# Scripts
*.sh
*.py

# Documentation
*.md
```

#### Check LFS Status

```bash
# List LFS tracked files
git lfs ls-files

# Check if file is tracked by LFS
git lfs status

# Migrate existing files to LFS
git lfs migrate import --include="*.x86_64"
```

---

## 🐳 Docker Conventions

### Dockerfile Standards

#### Base Image Selection

```dockerfile
# ✅ GOOD - Specific version
FROM ubuntu:22.04

# ❌ BAD - Latest tag (unpredictable)
FROM ubuntu:latest
```

#### Layer Optimization

```dockerfile
# ✅ GOOD - Combined RUN commands
RUN apt-get update && apt-get install -y \
    libglu1-mesa \
    libxcursor1 \
    && rm -rf /var/lib/apt/lists/*

# ❌ BAD - Multiple layers
RUN apt-get update
RUN apt-get install -y libglu1-mesa
RUN apt-get install -y libxcursor1
```

#### Security Best Practices

```dockerfile
# ✅ GOOD - Non-root user
RUN useradd -m -u 1000 cyberpoker
USER cyberpoker

# ❌ BAD - Running as root
# (No USER directive)
```

### Docker Compose Standards

#### Port Mapping

```yaml
# ✅ GOOD - Explicit protocol
ports:
  - "7770:7770/tcp"
  - "7770:7770/udp"

# ❌ BAD - Ambiguous
ports:
  - "7770:7770"
```

#### Environment Variables

```yaml
# ✅ GOOD - With defaults
environment:
  - SERVER_PORT=${SERVER_PORT:-7770}
  - MAX_PLAYERS=${MAX_PLAYERS:-10}

# ❌ BAD - No defaults
environment:
  - SERVER_PORT=${SERVER_PORT}
```

#### Resource Limits

```yaml
# ✅ GOOD - Define limits
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 4G
    reservations:
      cpus: '1'
      memory: 2G

# ❌ BAD - No limits (can consume all resources)
```

### Image Tagging

```bash
# ✅ GOOD - Semantic versioning
docker build -t cyberpoker-server:1.2.0 .
docker tag cyberpoker-server:1.2.0 cyberpoker-server:latest

# ❌ BAD - No versioning
docker build -t cyberpoker-server .
```

---

## 🚀 Deployment Process

### Deployment Environments

| Environment | Branch | URL | Auto-Deploy |
|-------------|--------|-----|-------------|
| **Production** | `main` | `play.cyberpoker.com:7770` | ✅ Yes |
| **Staging** | `staging` | `staging.cyberpoker.com:7770` | ✅ Yes |
| **Development** | `develop` | `dev.cyberpoker.com:7770` | ❌ Manual |

### Deployment Workflow

#### Automated (CI/CD)

```mermaid
graph LR
    A[Push to main] --> B[GitHub Actions]
    B --> C[Build Docker Image]
```

#### Manual Deployment

```bash
# 1. SSH into server
ssh deploy@your-server.com

# 2. Run deployment script
sudo /opt/cyberpoker-server/scripts/deploy.sh

# 3. Verify deployment
docker ps | grep cyberpoker-server
docker logs cyberpoker-server --tail 50

# 4. Test connection
./scripts/health-check.sh
```

### Pre-Deployment Checklist

Before merging to `main`:

- [ ] Build tested locally with Docker
- [ ] Environment variables documented
- [ ] CHANGELOG.md updated
- [ ] Breaking changes documented in commit message
- [ ] Deployment tested on staging
- [ ] Team notified of deployment
- [ ] Rollback plan prepared

### Post-Deployment Verification

```bash
# 1. Check server is running
docker ps | grep cyberpoker-server

# 2. Check logs for errors
docker logs cyberpoker-server | grep -i error

# 3. Test connection
nc -zv your-server.com 7770

# 4. Monitor for 5 minutes
watch -n 5 'docker stats cyberpoker-server --no-stream'
```

### Rollback Procedure

```bash
# Option 1: Using git
cd /opt/cyberpoker-server
git log --oneline -5  # Find previous commit
git reset --hard <previous-commit-hash>
docker-compose down
docker-compose up -d

# Option 2: Using script
./scripts/rollback.sh

# Option 3: Using Docker tags
docker-compose down
docker tag cyberpoker-server:1.1.0 cyberpoker-server:latest
docker-compose up -d
```

---

## 🔐 Environment Variables

### Required Variables

| Variable | Description | Example | Required |
|----------|-------------|---------|----------|
| `SERVER_PORT` | FishNet server port | `7770` | ✅ Yes |
| `MAX_PLAYERS` | Maximum concurrent players | `10` | ✅ Yes |
| `SERVER_NAME` | Server display name | `CyberPoker NA-East` | ✅ Yes |
| `LOG_LEVEL` | Logging verbosity | `INFO` | ❌ No (default: INFO) |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TICK_RATE` | Server tick rate | `30` |
| `TIMEOUT_SECONDS` | Player timeout | `30` |
| `ENABLE_METRICS` | Prometheus metrics | `false` |
| `BACKUP_ENABLED` | Auto backups | `true` |

### Environment File Structure

#### `.env` (Production)

```bash
# Server Configuration
SERVER_NAME=CyberPoker Production
SERVER_PORT=7770
MAX_PLAYERS=20

# Network
LISTEN_ADDRESS=0.0.0.0
TIMEOUT_SECONDS=30

# Performance
TICK_RATE=30
MAX_BANDWIDTH_KB=1024

# Logging
LOG_LEVEL=INFO
LOG_TO_FILE=true

# Security
ADMIN_PASSWORD=<use-secrets-manager>

# Monitoring
ENABLE_METRICS=true
METRICS_PORT=9090
```

#### `.env.staging`

```bash
# Server Configuration
SERVER_NAME=CyberPoker Staging
SERVER_PORT=7771
MAX_PLAYERS=5

# Network
LISTEN_ADDRESS=0.0.0.0
TIMEOUT_SECONDS=60  # More lenient for testing

# Logging
LOG_LEVEL=DEBUG  # More verbose for testing

# Monitoring
ENABLE_METRICS=true
```

### Managing Secrets

**❌ NEVER commit secrets to the repository**

#### Store secrets in:

1. **GitHub Secrets** (for CI/CD)
2. **Server environment** (for production)
3. **Password manager** (1Password, LastPass, etc.)

```bash
# ✅ GOOD - Using GitHub Secrets
${{ secrets.ADMIN_PASSWORD }}

# ✅ GOOD - Using environment
export ADMIN_PASSWORD=$(cat /etc/secrets/admin_password)

# ❌ BAD - Hardcoded
ADMIN_PASSWORD=mypassword123
```

---

## 🧪 Testing Requirements

### Local Testing Checklist

Before pushing any build:

```bash
# 1. Build Docker image
docker-compose build

# 2. Start server locally
docker-compose up

# 3. Check logs for errors
docker logs cyberpoker-server | grep -i error

# 4. Test connection (from another terminal)
nc -zv localhost 7770

# 5. Test with game client
# - Launch Unity client
# - Connect to localhost:7770
# - Create/join table
# - Play one full round

# 6. Stop server
docker-compose down
```

### Automated Tests

Currently, this repo focuses on **integration testing** via Docker.

#### Future: Add automated tests

```yaml
# .github/workflows/test.yml
name: Test Server Build

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: docker-compose build
      
      - name: Start server
        run: docker-compose up -d
      
      - name: Wait for server
        run: sleep 10
      
      - name: Health check
        run: |
          docker ps | grep cyberpoker-server
          docker logs cyberpoker-server | grep "Server started"
      
      - name: Port check
        run: nc -zv localhost 7770
      
      - name: Cleanup
        run: docker-compose down
```

---

## 📖 Documentation Standards

### Code Comments

```dockerfile
# ✅ GOOD - Explain WHY
# Using Ubuntu 22.04 for glibc 2.35 compatibility with Unity 2022.3
FROM ubuntu:22.04

# ❌ BAD - Explain WHAT (obvious)
# Install packages
RUN apt-get install -y libglu1-mesa
```
## 🔒 Security Guidelines

### Secrets Management

```bash
# ✅ GOOD - Use environment variables
docker run -e ADMIN_PASSWORD=$ADMIN_PASSWORD cyberpoker-server

# ❌ BAD - Hardcoded in Dockerfile
ENV ADMIN_PASSWORD=mypassword123
```

### File Permissions

```bash
# Scripts should be executable
chmod +x scripts/*.sh

# Configuration files should not be executable
chmod 644 config/*.json

# Environment files should be restricted
chmod 600 .env
```

### Docker Security

```dockerfile
# ✅ GOOD - Run as non-root user
RUN useradd -m -u 1000 cyberpoker
USER cyberpoker

# ✅ GOOD - Scan for vulnerabilities
# Run: docker scan cyberpoker-server:latest

# ✅ GOOD - Minimize attack surface
# Only install necessary packages
```

### Network Security

```yaml
# docker-compose.yml
services:
  cyberpoker-server:
    # ✅ GOOD - Explicit port binding
    ports:
      - "7770:7770"  # Only game port exposed
    
    # ❌ BAD - Expose all ports
    # network_mode: host
```

### Audit Trail

```bash
# All deployments logged
echo "$(date) - Deployed by $(whoami) - Commit $(git rev-parse HEAD)" >> /var/log/cyberpoker-deployments.log
```

---

## 🔧 Troubleshooting Guide

### Common Issues

#### Issue: Docker container won't start

```bash
# Check logs
docker logs cyberpoker-server

# Common causes:
# 1. Port already in use
sudo lsof -i :7770

# 2. Missing environment variables
docker-compose config

# 3. Corrupted build
rm -rf server/
# Re-copy from Unity build

# 4. Docker out of space
docker system prune -a
```

#### Issue: Server crashes on startup

```bash
# Check Unity dependencies
ldd server/Server.x86_64

# Missing libraries? Update Dockerfile:
RUN apt-get install -y missing-library
```

#### Issue: Can't connect to server

```bash
# 1. Check server is running
docker ps | grep cyberpoker

# 2. Check port is open
nc -zv your-server.com 7770

# 3. Check firewall
sudo ufw status
sudo ufw allow 7770/tcp
sudo ufw allow 7770/udp

# 4. Check Docker networking
docker network inspect bridge
```

#### Issue: High memory usage

```bash
# Check resource usage
docker stats cyberpoker-server

# Set memory limits in docker-compose.yml:
deploy:
  resources:
    limits:
      memory: 4G
```

### Debug Mode

```bash
# Enable verbose logging
export LOG_LEVEL=DEBUG
docker-compose up

# Attach to container
docker exec -it cyberpoker-server /bin/bash

# View real-time logs
docker logs -f cyberpoker-server
```

### Getting Help

1. **Check logs first**: `docker logs cyberpoker-server`
2. **Search issues**: GitHub Issues tab
3. **Ask in Discord**: #server-support channel
4. **Create issue**: Use issue template

---

## 📊 Monitoring and Metrics

### Health Checks

```bash
# Manual health check
curl http://localhost:9090/health

# Expected response:
# {"status":"healthy","uptime":3600,"players":5}
```

### Log Analysis

```bash
# Find errors
docker logs cyberpoker-server | grep -i error

# Count connections
docker logs cyberpoker-server | grep "Player connected" | wc -l

# Monitor in real-time
docker logs -f cyberpoker-server | grep -E "error|warning|crash"
```

### Performance Monitoring

```bash
# CPU and memory
docker stats cyberpoker-server

# Network traffic
docker exec cyberpoker-server netstat -i

# Disk usage
docker exec cyberpoker-server df -h
```

---

## 📝 Quick Reference

### Most Common Commands

```bash
# Build and start server
docker-compose up -d

# View logs
docker logs -f cyberpoker-server

# Restart server
docker-compose restart

# Stop server
docker-compose down

# Deploy latest changes
./scripts/deploy.sh

# Rollback to previous version
./scripts/rollback.sh

# Health check
./scripts/health-check.sh
```

### File Locations

| What | Where |
|------|-------|
| Server executable | `Server/Server.x86_64` |
| Docker config | `docker/docker-compose.yml` |
| Deploy script | `scripts/deploy.sh` |
| Environment vars | `.env` |
| Logs | `logs/` or `docker logs` |
| Conventions | `CONVENTIONS.md` (this file) |

---