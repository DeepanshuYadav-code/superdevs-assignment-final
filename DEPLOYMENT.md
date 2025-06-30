# 🚀 Deployment Guide

## Local Development Setup

### Prerequisites
- Rust (latest stable version)
- Git

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DeepanshuYadav-code/superdevs-assignment-final.git
   cd superdevs-assignment-final
   ```

2. **Build the project:**
   ```bash
   cargo build --release
   ```

3. **Run the server:**
   ```bash
   cargo run
   ```

4. **Test the endpoints:**
   ```bash
   # Make the scripts executable
   chmod +x *.sh
   
   # Run comprehensive tests
   ./test-new-format.sh
   ```

## Public Deployment

### Using ngrok (for development/testing)

1. **Install ngrok:**
   ```bash
   # Download from https://ngrok.com/
   # Or install via package manager
   ```

2. **Start the server:**
   ```bash
   cargo run
   ```

3. **Expose via ngrok (in another terminal):**
   ```bash
   ngrok http 3000
   ```

4. **Test public endpoints:**
   ```bash
   # Update the URL in test script and run
   ./test-public-new-format.sh
   ```

### Production Deployment Options

#### Docker Deployment
```bash
# Build Docker image
docker build -t solana-http-server .

# Run container
docker run -p 3000:3000 solana-http-server
```

#### Cloud Deployment (AWS/GCP/Azure)
- Deploy using container services
- Configure load balancer
- Set up SSL certificates
- Monitor with logging services

## Environment Configuration

### Required Environment Variables
```bash
# None required - server runs with defaults
# Port can be configured via environment variable
export PORT=3000
```

### Optional Configuration
- CORS origins can be modified in `src/main.rs`
- Logging levels can be adjusted
- Rate limiting can be added

## Monitoring & Maintenance

### Health Checks
```bash
# Check server health
curl http://localhost:3000/health

# Check API information
curl http://localhost:3000/
```

### Logs
- Server logs are printed to stdout
- Use systemd or Docker for log management in production

### Performance
- Built with Rust for high performance
- Async/await for concurrent request handling
- Minimal memory footprint

## Security Considerations

- All cryptographic operations use industry-standard libraries
- Secret keys are handled only in memory
- Input validation on all endpoints
- No private keys persisted to disk
- CORS configured for web applications

## Troubleshooting

### Common Issues

1. **Port already in use:**
   ```bash
   # Find process using port 3000
   lsof -i :3000
   # Kill the process
   kill <PID>
   ```

2. **Build errors:**
   ```bash
   # Update Rust
   rustup update
   # Clean build
   cargo clean && cargo build
   ```

3. **Network issues:**
   ```bash
   # Check firewall settings
   # Ensure port 3000 is open
   ```

## Support

For issues or questions:
- Check the main [README.md](./README.md)
- Review the [FINAL_SUBMISSION.md](./FINAL_SUBMISSION.md)
- Open an issue on GitHub
