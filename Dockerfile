# AdCraft AI — Hyper-Engine v2.0
# Production backend Dockerfile (Node.js API Gateway)
# Designed & Developed by Nikhil Chary Sriramoju

FROM node:20-slim AS base
WORKDIR /app

# ---- deps ----
FROM base AS deps
COPY package*.json ./
RUN npm ci --omit=dev

# ---- build ----
FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate
RUN npm run build

# ---- runtime ----
FROM base AS runtime
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
COPY --from=build /app/prisma ./prisma
COPY package*.json ./
EXPOSE 4000
CMD ["node", "dist/server.js"]
