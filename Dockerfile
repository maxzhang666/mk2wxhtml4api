# Stage 1: Dependencies
FROM node:22-alpine AS deps

# Install pnpm
RUN npm install -g pnpm

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Import npm lockfile and install dependencies
RUN pnpm import && pnpm install --prod


# Stage 2: Builder
FROM node:22-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copy package files
COPY package.json package-lock.json ./

# Import npm lockfile and install all dependencies
RUN pnpm import && pnpm install

# Copy application source
COPY src ./src
COPY temp ./temp


# Stage 3: Runner
FROM node:22-alpine AS runner

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/package.json ./package.json

# Copy application source
COPY --from=builder /app/src ./src
COPY --from=builder /app/temp ./temp

# Set ownership to non-root user
RUN chown -R nodejs:nodejs /app

# Switch to non-root user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Default command
CMD ["pnpm", "start"]
