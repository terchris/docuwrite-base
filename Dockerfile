# Base image
FROM --platform=$TARGETPLATFORM pandoc/latex:3.5-ubuntu

# Add metadata
LABEL maintainer="Terje Christensen" \
      version="0.1.6" \
      description="Container for creating documents and presentations using Pandoc, Mermaid, and Marp" \
      source="https://github.com/terchris/docuwrite-base" \
      documentation="https://github.com/terchris/docuwrite-base#readme"

# Set environment variables
ENV NODE_ENV=production \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install required dependencies, Node.js, and Chromium
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       gnupg \
       chromium-browser \
       fonts-ipafont-gothic \
       fonts-wqy-zenhei \
       fonts-thai-tlwg \
       fonts-khmeros \
       fonts-kacst \
       fonts-freefont-ttf \
       libxss1 \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a dedicated directory for npm packages
WORKDIR /usr/local/app

# Install Puppeteer, Mermaid CLI, and Marp CLI globally
RUN echo '{"dependencies": {"puppeteer": "22.0.0"}}' > package.json \
    && npm install --only=production \
    && npm install -g @mermaid-js/mermaid-cli@11.4.0 \
    && npm install -g @marp-team/marp-cli@4.0.3 \
    && npm cache clean --force

# Configure Puppeteer
RUN echo '{"executablePath": "/usr/bin/chromium-browser", "args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu"]}' > /usr/local/etc/puppeteer-config.json

# Create input and output directories with appropriate permissions
RUN mkdir -p /data/input /data/output \
    && chmod 777 /data/input /data/output

# Copy test files
COPY tests/ /usr/local/tests/

# Make test script executable
RUN chmod +x /usr/local/tests/test-install.sh \
    && ln -s /usr/local/tests/test-install.sh /usr/local/bin/test-install

# Set working directory to /data where mounted files will appear
WORKDIR /data

# Copy and set up the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD chromium-browser --version || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]