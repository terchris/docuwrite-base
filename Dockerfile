FROM --platform=$TARGETPLATFORM pandoc/latex:3.5-ubuntu

# Install Node.js
RUN apt-get update \
    && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs

# Install Chrome/Chromium based on architecture
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
        && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] https://dl-ssl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
        && apt-get update \
        && apt-get install -y google-chrome-stable \
        && echo 'export PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable' >> /etc/profile.d/chrome.sh; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
        apt-get update \
        && apt-get install -y chromium chromium-sandbox \
        && echo 'export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium' >> /etc/profile.d/chrome.sh; \
    fi

# Install common fonts and dependencies
RUN apt-get update \
    && apt-get install -y fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 \
    && rm -rf /var/lib/apt/lists/*

# Setup environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Set the correct PUPPETEER_EXECUTABLE_PATH based on architecture
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        echo "export PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable" >> ~/.bashrc; \
    else \
        echo "export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium" >> ~/.bashrc; \
    fi

# Create a dedicated directory for npm packages
WORKDIR /usr/local/app

# Install Puppeteer
RUN echo '{"dependencies": {"puppeteer": "^22.0.0"}}' > package.json \
    && npm install

# Install mermaid-cli globally
RUN npm install -g @mermaid-js/mermaid-cli --puppeteer-skip-download

# Install marp-cli globally
RUN npm install -g @marp-team/marp-cli

# Create architecture-specific Puppeteer config
RUN if [ "$(uname -m)" = "x86_64" ]; then \
        echo '{"args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu"]}' > /usr/local/etc/puppeteer-config.json; \
    else \
        echo '{"executablePath": "/usr/bin/chromium", "args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu"]}' > /usr/local/etc/puppeteer-config.json; \
    fi

# Copy test files
COPY tests/ /usr/local/tests/

# Make test script executable
RUN chmod +x /usr/local/tests/test-install.sh \
    && ln -s /usr/local/tests/test-install.sh /usr/local/bin/test-install

# Create input and output directories with appropriate permissions
RUN mkdir -p /data/input /data/output \
    && chmod 777 /data/input /data/output

# Set working directory to /data where mounted files will appear
WORKDIR /data

# Copy and set up the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# Create a wrapper script to ensure environment variables are set
RUN echo '#!/bin/bash\n\
if [ "$(uname -m)" = "aarch64" ]; then\n\
    export PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium\n\
else\n\
    export PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable\n\
fi\n\
exec /usr/local/bin/docker-entrypoint "$@"' > /usr/local/bin/wrapper.sh \
    && chmod +x /usr/local/bin/wrapper.sh

# Set the entrypoint to use our wrapper
ENTRYPOINT ["/usr/local/bin/wrapper.sh"]