# 🚀 DiceRollerSimulator Backend Deployment Guide

## Overview
This document provides enterprise-grade deployment instructions for the DiceRollerSimulator backend API to VPS `145.223.22.7`.

## 🎯 Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    VPS: 145.223.22.7                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │    Nginx    │    │    PM2      │    │  Node.js    │     │
│  │ (Port 80)   │───▶│ (Process    │───▶│ (Port 3000) │     │
│  │ Reverse     │    │  Manager)   │    │   API       │     │
│  │ Proxy       │    │             │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │   UFW       │    │ PostgreSQL  │    │   Redis     │     │
│  │ Firewall    │    │ Database    │    │   Cache     │     │
│  │             │    │             │    │             │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🔧 Prerequisites

Before deployment, ensure you have:

### Local Machine
- SSH access to the VPS (root user recommended)
- SSH keys configured for passwordless access
- `rsync` installed for file synchronization
- `curl` for testing endpoints

### VPS Requirements
- Ubuntu 20.04 LTS or later
- Minimum 2GB RAM, 2 CPU cores
- 20GB+ available disk space
- Internet connectivity
- SSH access enabled

## 📦 Quick Deployment

### 1. Make Deploy Script Executable
```bash
chmod +x deploy.sh
```

### 2. Run Deployment
```bash
./deploy.sh
```

The script will:
- ✅ Test VPS connectivity
- 📦 Package the application
- 📤 Upload files to VPS
- 🔧 Install dependencies (Node.js, PM2, Nginx)
- 🚀 Start the application
- 🌐 Configure reverse proxy
- 🔒 Set up firewall
- 🧪 Test deployment

## 🛠️ Manual Deployment Steps

If you prefer manual deployment or need to troubleshoot:

### Step 1: Prepare Local Environment
```bash
# Navigate to backend directory
cd /path/to/DiceRollerSimulator/backend

# Install dependencies locally (for testing)
npm install

# Run tests (if available)
npm test
```

### Step 2: Configure Production Environment
```bash
# Copy production environment template
cp .env.production .env.prod

# Edit with your actual values
nano .env.prod
```

### Step 3: Upload to VPS
```bash
# Create application directory
ssh root@145.223.22.7 "mkdir -p /opt/dicerollersimulator-backend"

# Upload files
rsync -avz --exclude node_modules --exclude .git ./ root@145.223.22.7:/opt/dicerollersimulator-backend/
```

### Step 4: Install Dependencies on VPS
```bash
ssh root@145.223.22.7 << 'EOF'
# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
apt-get install -y nodejs

# Install PM2 globally
npm install -g pm2

# Navigate to app directory
cd /opt/dicerollersimulator-backend

# Install production dependencies
npm ci --only=production

# Create logs directory
mkdir -p logs

# Set permissions
chown -R www-data:www-data /opt/dicerollersimulator-backend
chmod -R 755 /opt/dicerollersimulator-backend
EOF
```

### Step 5: Configure PM2 Process Manager
```bash
# Create PM2 ecosystem file
cat > /opt/dicerollersimulator-backend/ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'dicerollersimulator-backend',
    script: 'server.js',
    instances: 'max',
    exec_mode: 'cluster',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    log_file: 'logs/combined.log',
    out_file: 'logs/out.log',
    error_file: 'logs/error.log',
    max_restarts: 10,
    min_uptime: '10s',
    max_memory_restart: '500M'
  }]
};
EOF

# Start application with PM2
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

### Step 6: Configure Nginx Reverse Proxy
```bash
# Install Nginx
apt-get update
apt-get install -y nginx

# Create Nginx configuration
cat > /etc/nginx/sites-available/dicerollersimulator-api << 'EOF'
server {
    listen 80;
    server_name api.dicerollersimulator.com 145.223.22.7;

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
    }

    location /health {
        proxy_pass http://127.0.0.1:3000/health;
        access_log off;
    }
}
EOF

# Enable site
ln -s /etc/nginx/sites-available/dicerollersimulator-api /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

### Step 7: Configure Firewall
```bash
# Install UFW
apt-get install -y ufw

# Configure firewall rules
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable
```

## 🧪 Testing Deployment

### Health Check
```bash
curl http://145.223.22.7/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2024-07-18T12:00:00.000Z",
  "version": "v1"
}
```

### API Root
```bash
curl http://145.223.22.7/
```

Expected response:
```json
{
  "message": "DiceRollerSimulator API",
  "version": "v1",
  "documentation": "/api/v1/docs",
  "health": "/health"
}
```

### Test Stripe Endpoint
```bash
curl -X POST http://145.223.22.7/api/v1/stripe/create-payment-intent \
  -H "Content-Type: application/json" \
  -d '{"amount": 1000, "currency": "usd"}'
```

## 🔍 Monitoring & Maintenance

### View Application Logs
```bash
# PM2 logs
ssh root@145.223.22.7 "pm2 logs dicerollersimulator-backend"

# System logs
ssh root@145.223.22.7 "journalctl -u dicerollersimulator-backend -f"

# Nginx logs
ssh root@145.223.22.7 "tail -f /var/log/nginx/dicerollersimulator-api.access.log"
```

### Application Management
```bash
# Check status
ssh root@145.223.22.7 "pm2 status"

# Restart application
ssh root@145.223.22.7 "pm2 restart dicerollersimulator-backend"

# Stop application
ssh root@145.223.22.7 "pm2 stop dicerollersimulator-backend"

# Monitor resources
ssh root@145.223.22.7 "pm2 monit"
```

### System Health
```bash
# Check disk usage
ssh root@145.223.22.7 "df -h"

# Check memory usage
ssh root@145.223.22.7 "free -h"

# Check system load
ssh root@145.223.22.7 "uptime"
```

## 🔒 Security Considerations

### Environment Variables
- Store sensitive data in `.env` file on VPS
- Never commit `.env` files to version control
- Use strong, unique passwords and API keys
- Rotate secrets regularly

### SSL/TLS Certificate
```bash
# Install Certbot
apt-get install -y certbot python3-certbot-nginx

# Obtain SSL certificate
certbot --nginx -d api.dicerollersimulator.com

# Auto-renewal
crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

### Database Security
```bash
# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Create database and user
sudo -u postgres psql << 'EOF'
CREATE DATABASE diceroller_production;
CREATE USER diceroller_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE diceroller_production TO diceroller_user;
EOF
```

## 🚀 Production Optimizations

### Performance Tuning
```bash
# Configure PM2 for production
pm2 start ecosystem.config.js --env production --watch=false

# Enable log rotation
pm2 install pm2-logrotate
pm2 set pm2-logrotate:max_size 100M
pm2 set pm2-logrotate:compress true
pm2 set pm2-logrotate:retain 7
```

### Nginx Optimization
```nginx
# Add to nginx.conf
client_max_body_size 10M;
keepalive_timeout 65;
gzip on;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;
```

## 📊 API Endpoints

After deployment, the following endpoints will be available:

### Core Endpoints
- `GET /` - API information
- `GET /health` - Health check
- `GET /api/v1/docs` - API documentation

### Stripe Endpoints
- `POST /api/v1/stripe/create-payment-intent` - Create payment intent
- `POST /api/v1/stripe/webhook` - Stripe webhook handler

### Apple Endpoints
- `POST /api/v1/apple/verify-receipt` - Verify Apple receipt
- `POST /api/v1/apple/webhook` - Apple webhook handler

### User Endpoints
- `POST /api/v1/users/register` - Register user
- `POST /api/v1/users/login` - Login user
- `GET /api/v1/users/profile` - Get user profile

### Analytics Endpoints
- `POST /api/v1/analytics/track` - Track event
- `GET /api/v1/analytics/dashboard` - Analytics dashboard

## 🆘 Troubleshooting

### Common Issues

#### Application Won't Start
```bash
# Check logs
pm2 logs dicerollersimulator-backend

# Check environment variables
pm2 show dicerollersimulator-backend

# Restart with logs
pm2 restart dicerollersimulator-backend && pm2 logs
```

#### Database Connection Error
```bash
# Test database connection
psql -h localhost -U diceroller_user -d diceroller_production

# Check PostgreSQL status
systemctl status postgresql
```

#### Nginx 502 Error
```bash
# Check if Node.js app is running
pm2 status

# Check Nginx configuration
nginx -t

# Check Nginx logs
tail -f /var/log/nginx/error.log
```

### Emergency Rollback
```bash
# Stop current version
pm2 stop dicerollersimulator-backend

# Restore from backup
cd /opt/dicerollersimulator-backend
mv current current-failed
mv backup/$(ls -t backup/ | head -1) current

# Restart
pm2 start ecosystem.config.js --env production
```

## 🔄 Updates & Deployments

### Regular Updates
```bash
# Simply run the deploy script again
./deploy.sh
```

### Zero-Downtime Updates
```bash
# Use PM2 reload for zero-downtime
ssh root@145.223.22.7 "pm2 reload dicerollersimulator-backend"
```

## 📞 Support

For deployment issues or questions:
- Check logs first: `pm2 logs dicerollersimulator-backend`
- Review this documentation
- Check API health: `curl http://145.223.22.7/health`

## 🏆 Success Metrics

After successful deployment, you should see:
- ✅ API responding on `http://145.223.22.7`
- ✅ Health check returning "healthy"
- ✅ All endpoints accessible
- ✅ PM2 showing "online" status
- ✅ Nginx serving requests
- ✅ Firewall properly configured
- ✅ Logs being generated

---

**🎯 Your DiceRollerSimulator backend is now enterprise-ready and deployed!**
