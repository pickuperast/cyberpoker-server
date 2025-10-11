FROM ubuntu:22.04

# Set up DNS for package installation (fix DNS resolution issues)
RUN echo "nameserver 8.8.8.8" > /etc/resolv.conf && \
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Install runtime dependencies for Unity Linux build
# Using retries and longer timeout for flaky network connections
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends \
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
