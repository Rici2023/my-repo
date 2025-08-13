# backend/Dockerfile
# Stabilna baza na Debianie (mniej problemów z modułami natywnymi niż Alpine)
FROM node:20-bookworm-slim AS runtime
WORKDIR /app

# 1) Narzędzia do budowy modułów natywnych + sqlite (często wymagane przez sqlite3/better-sqlite3/bcrypt)
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
      python3 make g++ git pkg-config libsqlite3-dev ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# 2) Manifesty pakietów (lock opcjonalny)
COPY package*.json ./

# 3) Instalacja zależności produkcyjnych
#    - jeśli jest package-lock.json → npm ci
#    - jeśli nie ma locka → npm install
RUN npm set audit false && npm set fund false \
 && if [ -f package-lock.json ]; then \
      npm ci --omit=dev --no-audit --no-fund; \
    else \
      npm install --omit=dev --no-audit --no-fund; \
    fi

# 4) Reszta źródeł
COPY . .

# 5) Ustawienia runtime
ENV NODE_ENV=production
ENV PORT=3001
EXPOSE 3001

# 6) Sprzątanie cache
RUN npm cache clean --force || true

# 7) Start aplikacji
CMD ["node", "server.js"]
