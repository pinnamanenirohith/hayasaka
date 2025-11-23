# Base Image
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

RUN npm install

# Copy app source files
COPY . .

# Explicitly copy env file into /app
COPY .env.local /app/.env.local

# Build the Next.js project
RUN npm run build

# ----------------------------
# Production Runner Image
# ----------------------------

FROM node:18-alpine AS runner

WORKDIR /app

# Copy only necessary build output and dependencies
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/.env.local .env.local

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000

EXPOSE 3000

# ⭐ THIS is the line you were searching for ⭐
CMD ["npm", "start", "--", "-H", "0.0.0.0"]
