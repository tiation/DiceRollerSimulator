#!/bin/bash
# DiceRollerSimulator Backend Deployment Script
# Enterprise-grade deployment to VPS 145.223.22.7

set -e

# Configuration
VPS_IP="145.223.22.7"
VPS_USER="root"
APP_NAME="dicerollersimulator-backend"
APP_DIR="/opt/${APP_NAME}"
SERVICE_NAME="${APP_NAME}"
DOMAIN="api.dicerollersimulator.com"
PORT=3000

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 DiceRollerSimulator Backend Deployment${NC}"
echo -e "${CYAN}======================================${NC}"
echo -e "${BLUE}Target VPS: ${VPS_IP}${NC}"
echo -e "${BLUE}App Directory: ${APP_DIR}${NC}"
echo -e "${BLUE}Service: ${SERVICE_NAME}${NC}"
echo ""

# Check if we can connect to VPS
echo -e "${YELLOW}🔍 Checking VPS connection...${NC}"
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes ${VPS_USER}@${VPS_IP} exit 2>/dev/null; then
    echo -e "${RED}❌ Cannot connect to VPS ${VPS_IP}${NC}"
    echo -e "${YELLOW}Please ensure:${NC}"
    echo -e "  1. VPS is running and accessible"
    echo -e "  2. SSH key is properly configured"
    echo -e "  3. User '${VPS_USER}' exists on the VPS"
    exit 1
fi
echo -e "${GREEN}✅ VPS connection successful${NC}"

# Create deployment package
echo -e "${YELLOW}📦 Creating deployment package...${NC}"
rm -rf dist/
mkdir -p dist/
cp -r ./* dist/ 2>/dev/null || true
cp -r .env.example dist/.env.example 2>/dev/null || true
cd dist/

# Remove development dependencies and files
rm -rf node_modules/
rm -rf .git/
rm -rf logs/
rm -rf *.log
rm -rf .env

echo -e "${GREEN}✅ Deployment package created${NC}"

# Upload to VPS
echo -e "${YELLOW}📤 Uploading to VPS...${NC}"
ssh ${VPS_USER}@${VPS_IP} "mkdir -p ${APP_DIR}/backup"
ssh ${VPS_USER}@${VPS_IP} "[ -d ${APP_DIR}/current ] && mv ${APP_DIR}/current ${APP_DIR}/backup/\$(date +%Y%m%d_%H%M%S) || true"
ssh ${VPS_USER}@${VPS_IP} "mkdir -p ${APP_DIR}/current"

# Upload files
rsync -avz --progress ./ ${VPS_USER}@${VPS_IP}:${APP_DIR}/current/
echo -e "${GREEN}✅ Files uploaded successfully${NC}"

# Install dependencies and setup on VPS
echo -e "${YELLOW}🔧 Setting up application on VPS...${NC}"
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
# Install Node.js if not installed
if ! command -v node &> /dev/null; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Install PM2 if not installed
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    npm install -g pm2
fi

# Navigate to app directory
cd /opt/dicerollersimulator-backend/current

# Install dependencies
echo "Installing dependencies..."
npm ci --only=production

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "⚠️  Created .env file from example. Please configure it with your actual values."
fi

# Create logs directory
mkdir -p logs

# Set proper permissions
chown -R www-data:www-data /opt/dicerollersimulator-backend/
chmod -R 755 /opt/dicerollersimulator-backend/

echo "✅ Application setup complete"
EOF

# Create PM2 ecosystem file
echo -e "${YELLOW}📋 Creating PM2 ecosystem file...${NC}"
ssh ${VPS_USER}@${VPS_IP} "cat > ${APP_DIR}/ecosystem.config.js << 'EOL'
module.exports = {
  apps: [{
    name: '${SERVICE_NAME}',
    script: '${APP_DIR}/current/server.js',
    cwd: '${APP_DIR}/current',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: ${PORT}
    },
    env_production: {
      NODE_ENV: 'production',
      PORT: ${PORT}
    },
    log_file: '${APP_DIR}/logs/combined.log',
    out_file: '${APP_DIR}/logs/out.log',
    error_file: '${APP_DIR}/logs/error.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    max_restarts: 10,
    min_uptime: '10s',
    max_memory_restart: '500M',
    watch: false,
    ignore_watch: ['node_modules', 'logs'],
    time: true
  }]
};
EOL"

# Create systemd service
echo -e "${YELLOW}🔧 Creating systemd service...${NC}"
ssh ${VPS_USER}@${VPS_IP} "cat > /etc/systemd/system/${SERVICE_NAME}.service << 'EOL'
[Unit]
Description=DiceRollerSimulator Backend API
After=network.target

[Service]
Type=forking
User=www-data
Group=www-data
WorkingDirectory=${APP_DIR}/current
ExecStart=/usr/bin/pm2 start ${APP_DIR}/ecosystem.config.js --env production
ExecReload=/usr/bin/pm2 reload ${APP_DIR}/ecosystem.config.js --env production
ExecStop=/usr/bin/pm2 stop ${APP_DIR}/ecosystem.config.js
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL"

# Enable and start service
echo -e "${YELLOW}🚀 Starting service...${NC}"
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
systemctl daemon-reload
systemctl enable dicerollersimulator-backend
systemctl stop dicerollersimulator-backend 2>/dev/null || true
systemctl start dicerollersimulator-backend
sleep 5
systemctl status dicerollersimulator-backend --no-pager
EOF

# Setup Nginx reverse proxy
echo -e "${YELLOW}🌐 Setting up Nginx reverse proxy...${NC}"
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
# Install Nginx if not installed
if ! command -v nginx &> /dev/null; then
    echo "Installing Nginx..."
    apt-get update
    apt-get install -y nginx
fi

# Create Nginx configuration
cat > /etc/nginx/sites-available/dicerollersimulator-api << 'EOL'
server {
    listen 80;
    server_name api.dicerollersimulator.com 145.223.22.7;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
    limit_req zone=api burst=20 nodelay;

    # API proxy
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check endpoint
    location /health {
        proxy_pass http://127.0.0.1:3000/health;
        access_log off;
    }

    # Logging
    access_log /var/log/nginx/dicerollersimulator-api.access.log;
    error_log /var/log/nginx/dicerollersimulator-api.error.log;
}
EOL

# Enable the site
ln -sf /etc/nginx/sites-available/dicerollersimulator-api /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
systemctl enable nginx
systemctl start nginx

echo "✅ Nginx configuration complete"
EOF

# Setup firewall
echo -e "${YELLOW}🔒 Configuring firewall...${NC}"
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
# Install and configure UFW
if ! command -v ufw &> /dev/null; then
    apt-get install -y ufw
fi

# Set default policies
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Allow SSH
ufw allow ssh

# Allow HTTP and HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# Allow specific ports if needed
ufw allow 3000/tcp comment "Node.js API"

# Enable firewall
ufw --force enable
ufw status

echo "✅ Firewall configured"
EOF

# Test deployment
echo -e "${YELLOW}🧪 Testing deployment...${NC}"
echo -e "${BLUE}Testing health endpoint...${NC}"
if curl -s "http://${VPS_IP}/health" | grep -q "healthy"; then
    echo -e "${GREEN}✅ Health check passed${NC}"
else
    echo -e "${RED}❌ Health check failed${NC}"
fi

echo -e "${BLUE}Testing API root endpoint...${NC}"
if curl -s "http://${VPS_IP}/" | grep -q "DiceRollerSimulator API"; then
    echo -e "${GREEN}✅ API root endpoint working${NC}"
else
    echo -e "${RED}❌ API root endpoint failed${NC}"
fi

# Cleanup
cd ..
rm -rf dist/

echo ""
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo -e "${CYAN}======================================${NC}"
echo -e "${BLUE}Backend URL: http://${VPS_IP}${NC}"
echo -e "${BLUE}Health Check: http://${VPS_IP}/health${NC}"
echo -e "${BLUE}API Documentation: http://${VPS_IP}/api/v1/docs${NC}"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo -e "1. Configure your .env file on the VPS with actual values"
echo -e "2. Set up SSL certificate with Let's Encrypt"
echo -e "3. Configure your domain DNS to point to ${VPS_IP}"
echo -e "4. Test all API endpoints"
echo -e "5. Set up monitoring and backups"
echo ""
echo -e "${YELLOW}🔧 Management Commands:${NC}"
echo -e "• Check status: ssh ${VPS_USER}@${VPS_IP} 'systemctl status ${SERVICE_NAME}'"
echo -e "• View logs: ssh ${VPS_USER}@${VPS_IP} 'pm2 logs ${SERVICE_NAME}'"
echo -e "• Restart service: ssh ${VPS_USER}@${VPS_IP} 'systemctl restart ${SERVICE_NAME}'"
echo -e "• Update app: ./deploy.sh"
echo ""
