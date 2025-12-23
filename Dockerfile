FROM node:20-alpine AS base

# Install dependencies for building
RUN apk add --no-cache libc6-compat python3 make g++ wget

WORKDIR /app

# Copy package files
COPY package.json yarn.lock* ./

# Yarn is already available in node:20-alpine
RUN which yarn || npm install -g yarn

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Expose port
EXPOSE 9000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:9000/health || exit 1

# Start the server with migrations
CMD ["sh", "-c", "yarn db:migrate --execute-safe-links && yarn start"]

