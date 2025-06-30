# Multi-stage build for optimized production image
FROM rust:1.75-alpine as builder

# Install build dependencies
RUN apk add --no-cache musl-dev

# Create app directory
WORKDIR /usr/src/app

# Copy manifests
COPY Cargo.toml Cargo.lock ./

# Copy source code
COPY src ./src

# Build the application
RUN cargo build --release

# Production stage
FROM alpine:latest

# Install CA certificates for HTTPS
RUN apk add --no-cache ca-certificates

# Create app user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Create app directory
WORKDIR /app

# Copy the binary from builder stage
COPY --from=builder /usr/src/app/target/release/solana-http-server /app/

# Change ownership to app user
RUN chown -R appuser:appgroup /app

# Switch to app user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/keypair || exit 1

# Run the application
CMD ["./solana-http-server"]
