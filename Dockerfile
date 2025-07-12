FROM debian:bookworm-slim

ENV FLAMENCO_BIN_URL=https://flamenco.blender.org/downloads/flamenco-3.7-linux-amd64.tar.gz
ENV BLENDER_BIN_URL=https://download.blender.org/release/Blender4.4/blender-4.4.3-linux-x64.tar.xz

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    xz-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash flamenco

# Download and extract blender
RUN curl -L "$BLENDER_BIN_URL" -o blender.tar.xz && \
    mkdir /opt/blender && \
    tar -xf blender.tar.xz -C /opt/blender --strip-components=1 && \
    rm blender.tar.xz && \
    ln -s /opt/blender/blender /usr/local/bin/blender

# Download and extract Flamenco worker
RUN curl -L "$FLAMENCO_BIN_URL" -o flamenco.tar.gz && \
    mkdir /opt/flamenco && \
    tar -xf flamenco.tar.gz -C /opt/flamenco --strip-components=1 && \
    rm flamenco.tar.gz && \
    ln -s /opt/flamenco/flamenco-worker /usr/local/bin/flamenco-worker && \
    ln -s /opt/flamenco/flamenco-manager /usr/local/bin/flamenco-manager

# Make writable non-root working dir
WORKDIR /app
RUN chown -R flamenco:flamenco /app
USER flamenco

# Expose the default Flamenco Manager port
EXPOSE 8080

# Smoke test to check the app is actually present and runs
RUN blender --version
RUN flamenco-worker -version
RUN flamenco-manager -version

# Start the manager
CMD ["flamenco-worker"]