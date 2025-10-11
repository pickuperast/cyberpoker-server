FROM ubuntu:22.04

# Create app directory
WORKDIR /app

# Copy server files
COPY server/ /app/

# Make server executable
RUN chmod +x /app/Server.x86_64

# Expose game port (adjust to your FishNet port)
EXPOSE 7770/tcp
EXPOSE 7770/udp

# Run the server in headless mode (no graphics, no display needed)
CMD ["/app/Server.x86_64", "-batchmode", "-nographics", "-logFile", "-"]
