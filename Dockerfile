FROM debian:bookworm-slim

# Set environment
ENV FLAMENCO_VERSION=3.7
ENV FLAMENCO_BIN_URL=https://flamenco.blender.org/downloads/flamenco-${FLAMENCO_VERSION}-linux-amd64.tar.gz

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash flamenco

# Download and extract Flamenco worker
WORKDIR /opt
RUN curl -L "$FLAMENCO_BIN_URL" -o flamenco.tar.xz && \
    mkdir /opt/flamenco && \
    tar -xf flamenco.tar.xz -C /opt/flamenco --strip-components=1 && \
    rm flamenco.tar.xz && \
    chown -R flamenco:flamenco /opt/flamenco

USER flamenco
WORKDIR /opt/flamenco

# Expose the default Flamenco Manager port
EXPOSE 8080

# Smoke test to check the app is actually present and runs
RUN flamenco-worker -version

# Start the manager
CMD ["./flamenco-worker"]