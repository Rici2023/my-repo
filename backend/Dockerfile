# backend/Dockerfile
FROM node:20-alpine AS runtime
WORKDIR /app

# kopiujemy package.json i (ewentualnie) package-lock.json, jeśli istnieje
COPY package*.json ./

# instalacja zależności produkcyjnych
# jeśli nie ma locka, npm ci zwróci błąd – fallback do npm install
RUN npm ci --omit=dev --no-audit --no-fund || \
    npm install --only=production --no-audit --no-fund

# reszta źródeł
COPY . .

ENV NODE_ENV=production
ENV PORT=3001
EXPOSE 3001

CMD ["node", "server.js"]
