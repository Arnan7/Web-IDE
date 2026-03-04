
# stage de build: instala dependencias y genera la carpeta .next
FROM node:18-alpine AS builder

WORKDIR /app

# copiar manifiestos primero para aprovechar el cache de npm
COPY package*.json ./
RUN npm ci

# copiar el resto del código y compilar
COPY . .
RUN npm run build

# eliminar dependencias de desarrollo para reducir el artefacto final
# (npm prune actúa sobre node_modules ya instalado)
RUN npm prune --production

# etapa final más ligera para producción
FROM node:18-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production

# sólo traemos lo estrictamente necesario
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public

EXPOSE 3000
CMD ["npm", "start"]
