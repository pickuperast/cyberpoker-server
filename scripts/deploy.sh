#!/bin/bash

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting CyberPoker Server Deployment...${NC}"

# Configuration
REPO_URL="https://github.com/your-username/cyberpoker-server.git"
DEPLOY_DIR="/opt/cyberpoker-server"
BRANCH="main"

# Function to print colored messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then 
    log_error "Please run as root or with sudo"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Stop existing container if running
log_info "Stopping existing server..."
cd "$DEPLOY_DIR" 2>/dev/null && docker-compose down || log_warn "No existing server to stop"

# Create deploy directory if it doesn't exist
if [ ! -d "$DEPLOY_DIR" ]; then
    log_info "Creating deploy directory: $DEPLOY_DIR"
    mkdir -p "$DEPLOY_DIR"
    cd "$DEPLOY_DIR"
    
    log_info "Cloning repository..."
    git clone "$REPO_URL" .
else
    log_info "Updating repository..."
    cd "$DEPLOY_DIR"
    git fetch origin
    git reset --hard "origin/$BRANCH"
    git pull origin "$BRANCH"
fi

# Load environment variables
if [ -f .env ]; then
    log_info "Loading environment variables..."
    export $(cat .env | grep -v '^#' | xargs)
else
    log_warn ".env file not found, using defaults"
fi

# Build Docker image
log_info "Building Docker image..."
docker-compose -f docker/docker-compose.yml build

# Start the server
log_info "Starting CyberPoker server..."
docker-compose -f docker/docker-compose.yml up -d

# Wait for server to start
log_info "Waiting for server to start..."
sleep 5

# Check if container is running
if docker ps | grep -q cyberpoker-server; then
    log_info "Server is running!"
    log_info "Checking logs..."
    docker logs cyberpoker-server --tail 20
    
    echo ""
    log_info "Deployment completed successfully! 🎉"
    log_info "Server is accessible on port ${SERVER_PORT:-7770}"
    echo ""
    echo "Useful commands:"
    echo "  View logs:    docker logs -f cyberpoker-server"
    echo "  Stop server:  docker-compose -f $DEPLOY_DIR/docker/docker-compose.yml down"
    echo "  Restart:      docker-compose -f $DEPLOY_DIR/docker/docker-compose.yml restart"
else
    log_error "Server failed to start. Check logs:"
    docker logs cyberpoker-server
    exit 1
fi