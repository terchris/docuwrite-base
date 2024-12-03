FROM pandoc/latex:3.5-ubuntu
# Based on Ubuntu 22.04 LTS (Jammy Jellyfish)

LABEL maintainer="Terje Christensen" \
      version="0.1.7" \
      description="Container for creating documents and presentations using Pandoc, Mermaid, and Marp" \
      source="https://github.com/terchris/docuwrite-base" \
      documentation="https://github.com/terchris/docuwrite-base#readme"

# Basic environment settings
ENV NODE_ENV=production \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Virtual display configuration
ENV XVFB_DISPLAY=:99 \
    XVFB_SCREEN=0 \
    XVFB_RESOLUTION="1024x768x24" \
    DISPLAY=:99

# Application paths
ENV APP_DIR=/usr/local/app \
    TEST_DIR=/usr/local/tests \
    NODE_PATH=/usr/local/app/node_modules \
    PUPPETEER_CONFIG=/usr/local/etc/puppeteer-config.json

# Package installation explanation:
# Core system utilities:
#   ca-certificates: Required for HTTPS connections
#   curl: Required for downloading resources
#   gnupg: Required for repository key management
#   wget: Required for downloading Firefox repository
# Display server:
#   xvfb: Virtual framebuffer for Firefox headless mode
# Font packages required by Marp:
#   fonts-ipafont-gothic: Japanese fonts
#   fonts-wqy-zenhei: Chinese fonts
#   fonts-thai-tlwg: Thai fonts
#   fonts-khmeros: Khmer fonts
#   fonts-kacst: Arabic fonts
#   fonts-freefont-ttf: Base free fonts

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       gnupg \
       wget \
       xvfb \
       fonts-ipafont-gothic \
       fonts-wqy-zenhei \
       fonts-thai-tlwg \
       fonts-khmeros \
       fonts-kacst \
       fonts-freefont-ttf \
    && mkdir -p /etc/apt/keyrings \
    # Add Firefox Repository
    && wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null \
    && echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null \
    # Add NodeJS Repository
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
       nodejs \
       firefox-nightly \
    && npm install -g npm@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR ${APP_DIR}

# Install node packages
RUN npm init -y \
    && npm install puppeteer-core \
    && npm install -g @mermaid-js/mermaid-cli@11.4.0 \
    && npm install -g @marp-team/marp-cli@4.0.3 \
    && npm cache clean --force

# Configure puppeteer for Firefox with WebDriver BiDi support
RUN echo '{\n\
  "browser": "firefox",\n\
  "executablePath": "/usr/bin/firefox-nightly",\n\
  "headless": "new",\n\
  "args": ["--no-sandbox"],\n\
  "product": "firefox"\n\
}' > ${PUPPETEER_CONFIG}

# Set up data directories
RUN mkdir -p /data/input /data/output \
    && chmod 777 /data/input /data/output

# Copy test files
COPY tests/ ${TEST_DIR}/

# Set up test script
RUN chmod +x ${TEST_DIR}/test-install.sh \
    && ln -s ${TEST_DIR}/test-install.sh /usr/local/bin/test-install

# Set up entrypoint
WORKDIR /data
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# Start Xvfb at container startup
RUN echo "#!/bin/bash\nXvfb \${XVFB_DISPLAY} -screen \${XVFB_SCREEN} \${XVFB_RESOLUTION} > /dev/null 2>&1 &\nsleep 2\n\$@" > /usr/local/bin/start-with-xvfb \
    && chmod +x /usr/local/bin/start-with-xvfb

# Healthcheck to verify Firefox and display
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD xdpyinfo -display ${DISPLAY} >/dev/null 2>&1 && \
        node -e "const puppeteer = require('puppeteer-core'); (async () => { const browser = await puppeteer.launch({ browser: 'firefox', executablePath: '/usr/bin/firefox-nightly', headless: 'new' }); await browser.close(); })()" || exit 1

ENTRYPOINT ["/usr/local/bin/start-with-xvfb", "/usr/local/bin/docker-entrypoint"]