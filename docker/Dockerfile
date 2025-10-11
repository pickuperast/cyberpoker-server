FROM ubuntu:22.04

# Install runtime dependencies for Unity Linux build
RUN apt-get update && apt-get install -y \
    libglu1-mesa \
    libxcursor1 \
    libxrandr2 \
    libxi6 \
    libxinerama1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy server files
COPY server/ /app/

# Make server executable
RUN chmod +x /app/Server.x86_64

# Expose game port (adjust to your FishNet port)
EXPOSE 7770/tcp
EXPOSE 7770/udp

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD netstat -an | grep 7770 || exit 1

# Run the server
CMD ["/app/Server.x86_64", "-batchmode", "-nographics", "-logFile", "/app/logs/server.log"]