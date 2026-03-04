
# stage de build: instala dependencias y genera la carpeta .next
FROM node:18-alpine AS builder

WORKDIR /app

# copiar manifiestos primero para aprovechar el cache de npm
COPY package*.json ./
RUN npm ci

# copiar el resto del código y compilar
COPY . .
RUN npm run build

# opcional: limpiar cache del builder
RUN npm cache clean --force

# etapa final más ligera para producción
FROM node:18-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

# copiamos artefactos de build
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

# instalamos únicamente dependencias de producción
RUN npm ci --production

EXPOSE 3000
CMD ["npm", "start"]
