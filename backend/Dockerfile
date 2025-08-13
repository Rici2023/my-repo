# backend/Dockerfile
FROM node:20-bookworm-slim AS runtime
WORKDIR /app

# 1) Toolchain do modułów natywnych + sqlite
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      python3 make g++ git pkg-config libsqlite3-dev ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 2) Manifesty pakietów (lock opcjonalny)
COPY package*.json ./

# 3) Preflight: upewnij się, że package.json istnieje (inaczej build nie ma sensu)
RUN ls -la && test -f package.json || (echo '❌ Brak backend/package.json w kontekście budowy. Sprawdź compose.yaml: build.context: ./backend' && exit 1)

# 4) Konfiguracja npm i odporna instalacja zależności
RUN npm set audit false && npm set fund false \
 && npm config set progress false \
 && npm config set fetch-retry-maxtimeout 600000 \
 && if [ -f package-lock.json ]; then \
      npm ci --omit=dev --legacy-peer-deps --no-audit --no-fund \
      || npm ci --omit=dev --force \
      || npm install --omit=dev --legacy-peer-deps --no-audit --no-fund; \
    else \
      npm install --omit=dev --legacy-peer-deps --no-audit --no-fund \
      || npm install --omit=dev --force; \
    fi

# 5) Reszta źródeł
COPY . .

# 6) Rebuild natywnych modułów i opcjonalny build (nie zrywaj builda jeśli brak)
RUN npm rebuild better-sqlite3 sqlite3 bcrypt --build-from-source --no-audit --no-fund || true \
 && npm run build --if-present || true \
 && npm cache clean --force || true

# 7) Runtime
ENV NODE_ENV=production
ENV PORT=3001
EXPOSE 3001

CMD ["node", "server.js"]
