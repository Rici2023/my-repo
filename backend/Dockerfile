# backend/Dockerfile
FROM node:20-alpine AS runtime
WORKDIR /app

# 1) systemowe zależności do budowy modułów natywnych
#    - .build-deps: tylko na czas builda
#    - sqlite-libs: biblioteka runtime (zostaje)
RUN apk add --no-cache --virtual .build-deps python3 make g++ pkgconfig sqlite-dev \
    && apk add --no-cache sqlite-libs

# 2) paczki npm: kopiujemy manifesty (lock opcjonalny)
COPY package*.json ./

# 3) instalacja prod zależności (fallback jeśli nie ma package-lock.json)
#    wyłączamy "audit" i "fund", żeby logi były czyste
RUN npm set audit false && npm set fund false \
    && ( npm ci --omit=dev || npm install --omit=dev )

# 4) reszta źródeł
COPY . .

ENV NODE_ENV=production
ENV PORT=3001
EXPOSE 3001

# 5) sprzątanie: cache npm + usunięcie narzędzi buildowych
RUN npm cache clean --force || true \
    && apk del .build-deps || true

CMD ["node", "server.js"]
