FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --omit=dev
COPY . .
RUN mkdir -p /app/data && node scripts/seed.js
EXPOSE 3001
CMD ["node", "server.js"]
