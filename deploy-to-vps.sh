#!/bin/bash

# DiceRollerSimulator VPS Deployment Script
# Deploys the Node.js backend to VPS at 145.223.22.7

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
LOCAL_PROJECT_PATH="/Users/tiaastor/tiation-github/DiceRollerSimulator"
VPS_PATH="/Users/tiaastor/Library/CloudStorage/ShellFish/Homebase/145.223.22.7/tiation-github/DiceRollerSimulator"
BACKEND_PATH="$VPS_PATH/backend"
SERVICE_NAME="diceroller-api"
PORT=3000

echo -e "${CYAN}🎲 DiceRollerSimulator VPS Deployment${NC}"
echo -e "${CYAN}======================================${NC}"

# Check if local project exists
if [ ! -d "$LOCAL_PROJECT_PATH" ]; then
    echo -e "${RED}❌ Local project directory not found: $LOCAL_PROJECT_PATH${NC}"
    exit 1
fi

# Check if VPS is mounted
if [ ! -d "$VPS_PATH" ]; then
    echo -e "${RED}❌ VPS path not found: $VPS_PATH${NC}"
    echo -e "${YELLOW}💡 Make sure your VPS is mounted via ShellFish${NC}"
    exit 1
fi

echo -e "${BLUE}📁 Syncing project files to VPS...${NC}"

# Create backup of existing deployment
if [ -d "$VPS_PATH" ]; then
    echo -e "${YELLOW}🔄 Creating backup of existing deployment...${NC}"
    cp -r "$VPS_PATH" "$VPS_PATH.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null || true
fi

# Sync all files except .git and node_modules
echo -e "${BLUE}🔄 Syncing project files...${NC}"
rsync -av --exclude='.git' --exclude='node_modules' --exclude='*.xcarchive' --exclude='build' --exclude='DerivedData' "$LOCAL_PROJECT_PATH/" "$VPS_PATH/"

# Check if backend directory exists
if [ ! -d "$BACKEND_PATH" ]; then
    echo -e "${RED}❌ Backend directory not found after sync${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Files synced successfully${NC}"

# Create environment file for production
echo -e "${BLUE}🔧 Setting up environment configuration...${NC}"
cat > "$BACKEND_PATH/.env" << EOF
# Production Environment Configuration
NODE_ENV=production
PORT=$PORT
APP_NAME=DiceRollerSimulator
API_VERSION=v1

# CORS Configuration
CORS_ORIGINS=https://diceroller.tiation.com,https://api.diceroller.tiation.com

# Rate Limiting
RATE_LIMIT_WINDOW=15
RATE_LIMIT_MAX_REQUESTS=100

# Security
JWT_SECRET=\$(openssl rand -hex 32)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Database (if using PostgreSQL)
DATABASE_URL=postgresql://user:password@localhost:5432/diceroller

# Logging
LOG_LEVEL=info
LOG_DIR=/var/log/diceroller
EOF

# Create PM2 ecosystem file for process management
echo -e "${BLUE}🔧 Creating PM2 ecosystem configuration...${NC}"
cat > "$BACKEND_PATH/ecosystem.config.js" << EOF
module.exports = {
  apps: [{
    name: '$SERVICE_NAME',
    script: './server.js',
    cwd: '$BACKEND_PATH',
    instances: 1,
    exec_mode: 'cluster',
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: $PORT
    },
    error_file: '/var/log/diceroller/err.log',
    out_file: '/var/log/diceroller/out.log',
    log_file: '/var/log/diceroller/combined.log',
    time: true
  }]
};
EOF

# Create nginx configuration
echo -e "${BLUE}🔧 Creating nginx configuration...${NC}"
cat > "$BACKEND_PATH/nginx.conf" << EOF
server {
    listen 80;
    server_name api.diceroller.tiation.com;
    
    # Redirect HTTP to HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.diceroller.tiation.com;
    
    # SSL configuration (you'll need to set up certificates)
    ssl_certificate /etc/letsencrypt/live/api.diceroller.tiation.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.diceroller.tiation.com/privkey.pem;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    
    # API proxy
    location / {
        proxy_pass http://localhost:$PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        proxy_pass http://localhost:$PORT/health;
    }
}
EOF

# Create systemd service file
echo -e "${BLUE}🔧 Creating systemd service configuration...${NC}"
cat > "$BACKEND_PATH/diceroller-api.service" << EOF
[Unit]
Description=DiceRollerSimulator API Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=$BACKEND_PATH
ExecStart=/usr/bin/node server.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=$PORT
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=diceroller-api

[Install]
WantedBy=multi-user.target
EOF

# Create deployment README
echo -e "${BLUE}📝 Creating deployment documentation...${NC}"
cat > "$BACKEND_PATH/DEPLOYMENT.md" << EOF
# DiceRollerSimulator Backend Deployment

## VPS Deployment Guide

### Prerequisites
- Node.js 18+ installed
- PM2 process manager
- Nginx web server
- SSL certificates (Let's Encrypt recommended)
- PostgreSQL database (if using)

### Installation Steps

1. **Install Node.js dependencies:**
   \`\`\`bash
   cd $BACKEND_PATH
   npm install --production
   \`\`\`

2. **Set up environment variables:**
   - Edit \`.env\` file with your actual credentials
   - Generate JWT secret: \`openssl rand -hex 32\`
   - Add your Stripe API keys

3. **Install PM2 globally:**
   \`\`\`bash
   npm install -g pm2
   \`\`\`

4. **Start the application:**
   \`\`\`bash
   pm2 start ecosystem.config.js
   pm2 save
   pm2 startup
   \`\`\`

5. **Configure Nginx:**
   \`\`\`bash
   sudo cp nginx.conf /etc/nginx/sites-available/diceroller-api
   sudo ln -s /etc/nginx/sites-available/diceroller-api /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   \`\`\`

6. **Set up SSL certificates:**
   \`\`\`bash
   sudo certbot --nginx -d api.diceroller.tiation.com
   \`\`\`

### Management Commands

- **Start service:** \`pm2 start $SERVICE_NAME\`
- **Stop service:** \`pm2 stop $SERVICE_NAME\`
- **Restart service:** \`pm2 restart $SERVICE_NAME\`
- **View logs:** \`pm2 logs $SERVICE_NAME\`
- **Monitor:** \`pm2 monit\`

### Health Check
- URL: https://api.diceroller.tiation.com/health
- Expected response: \`{"status": "healthy", "timestamp": "...", "version": "v1"}\`

### Troubleshooting

1. **Check if service is running:**
   \`\`\`bash
   pm2 status
   \`\`\`

2. **Check logs:**
   \`\`\`bash
   pm2 logs $SERVICE_NAME --lines 50
   \`\`\`

3. **Test API locally:**
   \`\`\`bash
   curl http://localhost:$PORT/health
   \`\`\`

### Security Considerations

- Keep dependencies updated: \`npm audit\`
- Use environment variables for secrets
- Enable firewall rules
- Regular security updates
- Monitor access logs

### Backup Strategy

- Database backups (if using PostgreSQL)
- Environment configuration backup
- Code repository backup
- SSL certificates backup

---

Deployed on: $(date)
Version: $(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
EOF

# Create quick start script
echo -e "${BLUE}🚀 Creating quick start script...${NC}"
cat > "$BACKEND_PATH/quick-start.sh" << 'EOF'
#!/bin/bash

# Quick Start Script for DiceRollerSimulator Backend
set -e

echo "🎲 DiceRollerSimulator Backend Quick Start"
echo "=========================================="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18+ first."
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node --version | cut -d'v' -f2)
REQUIRED_VERSION="18.0.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Node.js version $NODE_VERSION is too old. Please upgrade to 18.0.0 or higher."
    exit 1
fi

echo "✅ Node.js version: $NODE_VERSION"

# Install dependencies
echo "📦 Installing dependencies..."
npm install --production

# Check if PM2 is installed
if ! command -v pm2 &> /dev/null; then
    echo "📦 Installing PM2..."
    npm install -g pm2
fi

# Start the application
echo "🚀 Starting DiceRollerSimulator API..."
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Setup PM2 startup
pm2 startup

echo "✅ DiceRollerSimulator API is now running!"
echo "🌐 API URL: http://localhost:3000"
echo "❤️  Health Check: http://localhost:3000/health"
echo "📊 Monitor: pm2 monit"
echo "📋 Logs: pm2 logs diceroller-api"

# Test the API
echo "🧪 Testing API..."
sleep 3
curl -s http://localhost:3000/health | python3 -m json.tool || echo "⚠️  API test failed - check logs"

echo "🎉 Deployment completed successfully!"
EOF

chmod +x "$BACKEND_PATH/quick-start.sh"

echo -e "${GREEN}✅ Deployment files created successfully!${NC}"
echo -e "${CYAN}📋 Next Steps:${NC}"
echo -e "${YELLOW}1. Connect to your VPS via SSH${NC}"
echo -e "${YELLOW}2. Navigate to: $BACKEND_PATH${NC}"
echo -e "${YELLOW}3. Run: ./quick-start.sh${NC}"
echo -e "${YELLOW}4. Configure your domain and SSL certificates${NC}"
echo -e "${YELLOW}5. Update environment variables in .env${NC}"

echo -e "${CYAN}🔗 API Endpoints after deployment:${NC}"
echo -e "${BLUE}   Health: http://your-vps-ip:3000/health${NC}"
echo -e "${BLUE}   API: http://your-vps-ip:3000/api/v1/${NC}"
echo -e "${BLUE}   Docs: http://your-vps-ip:3000/api/v1/docs${NC}"

echo -e "${GREEN}🎉 VPS deployment preparation completed!${NC}"
