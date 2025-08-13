# backend/Dockerfile
FROM node:20-bookworm-slim AS runtime
WORKDIR /app

# Narzędzia do modułów natywnych + sqlite
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      python3 make g++ git pkg-config libsqlite3-dev ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Manifesty (lock opcjonalny)
COPY package*.json ./

# Instalacja prod-deps (bez skryptów; toleruje konflikty peer-deps)
RUN npm set audit false && npm set fund false \
 && if [ -f package-lock.json ]; then \
      npm ci --omit=dev --ignore-scripts --no-audit --no-fund --legacy-peer-deps; \
    else \
      npm install --omit=dev --ignore-scripts --no-audit --no-fund --legacy-peer-deps; \
    fi

# Reszta źródeł
COPY . .

# (opcjonalnie) Rebuild natywnych modułów, nie przerywaj builda jeśli brak
RUN npm rebuild better-sqlite3 sqlite3 bcrypt --build-from-source --no-audit --no-fund || true \
 && npm run build --if-present || true \
 && npm cache clean --force || true

ENV NODE_ENV=production
ENV PORT=3001
EXPOSE 3001

CMD ["node", "server.js"]
