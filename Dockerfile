FROM pandoc/latex:3.5-ubuntu

# Install Node.js
RUN apt-get update \
    && apt-get install -y ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs

# Install Chrome
RUN apt-get update \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] https://dl-ssl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 \
    && rm -rf /var/lib/apt/lists/*

# Setup environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Create a dedicated directory for npm packages
WORKDIR /usr/local/app

# Install Puppeteer
RUN echo '{"dependencies": {"puppeteer": "^22.0.0"}}' > package.json \
    && npm install

# Install mermaid-cli globally
RUN npm install -g @mermaid-js/mermaid-cli --puppeteer-skip-download

# Install marp-cli globally
RUN npm install -g @marp-team/marp-cli

# Create Puppeteer config file in a system location
RUN echo '{ \
    "args": ["--no-sandbox", "--disable-setuid-sandbox"] \
    }' > /usr/local/etc/puppeteer-config.json

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

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]