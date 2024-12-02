# Base image
FROM --platform=$TARGETPLATFORM pandoc/latex:3.5-ubuntu

LABEL maintainer="Terje Christensen" \
      version="0.1.7" \
      description="Container for creating documents and presentations using Pandoc, Mermaid, and Marp" \
      source="https://github.com/terchris/docuwrite-base" \
      documentation="https://github.com/terchris/docuwrite-base#readme"

ENV NODE_ENV=production \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       curl \
       gnupg \
       fonts-ipafont-gothic \
       fonts-wqy-zenhei \
       fonts-thai-tlwg \
       fonts-khmeros \
       fonts-kacst \
       fonts-freefont-ttf \
       libxss1 \
       libnss3 \
       libnspr4 \
       libatk1.0-0 \
       libatk-bridge2.0-0 \
       libcups2 \
       libdrm2 \
       libxkbcommon0 \
       libxcomposite1 \
       libxdamage1 \
       libxfixes3 \
       libxrandr2 \
       libgbm1 \
       libasound2 \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g npm@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

RUN echo '{"dependencies": {"puppeteer": "23.9.0"}}' > package.json \
    && npm install --only=production \
    && npm install -g @mermaid-js/mermaid-cli@11.4.0 \
    && npm install -g @marp-team/marp-cli@4.0.3 \
    && npm cache clean --force

RUN echo '{"args": ["--no-sandbox", "--disable-setuid-sandbox", "--disable-gpu"]}' > /usr/local/etc/puppeteer-config.json

RUN mkdir -p /data/input /data/output \
    && chmod 777 /data/input /data/output

COPY tests/ /usr/local/tests/

RUN chmod +x /usr/local/tests/test-install.sh \
    && ln -s /usr/local/tests/test-install.sh /usr/local/bin/test-install

WORKDIR /data

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD node -e "const puppeteer = require('puppeteer'); (async () => { const browser = await puppeteer.launch(); await browser.close(); })()" || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint"]