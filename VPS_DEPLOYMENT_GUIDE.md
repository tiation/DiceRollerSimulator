# 🎲 DiceRollerSimulator VPS Deployment Guide

## Overview
This guide walks you through deploying the DiceRollerSimulator Node.js backend to your VPS at `145.223.22.7`.

## Prerequisites
- VPS access via SSH
- Node.js 18+ installed on VPS
- Domain configured (optional: api.diceroller.tiation.com)
- SSL certificate setup (recommended)

## Step 1: Connect to Your VPS

```bash
# Connect to your VPS via SSH
ssh root@145.223.22.7

# Or if you have a specific user:
ssh your_username@145.223.22.7
```

## Step 2: Navigate to Backend Directory

```bash
cd /root/tiation-github/DiceRollerSimulator/backend
# or wherever your files are located on the VPS
```

## Step 3: Quick Start Deployment

```bash
# Make the script executable
chmod +x quick-start.sh

# Run the deployment
./quick-start.sh
```

## Step 4: Configure Environment Variables

```bash
# Edit the environment file
nano .env

# Update these critical values:
# - JWT_SECRET: Generate with: openssl rand -hex 32
# - STRIPE_SECRET_KEY: Your actual Stripe secret key
# - STRIPE_WEBHOOK_SECRET: Your Stripe webhook secret
# - DATABASE_URL: Your PostgreSQL connection string (if using)
```

## Step 5: Set Up SSL and Domain (Optional)

```bash
# Install Certbot for SSL certificates
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d api.diceroller.tiation.com

# Configure Nginx
sudo cp nginx.conf /etc/nginx/sites-available/diceroller-api
sudo ln -s /etc/nginx/sites-available/diceroller-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Step 6: Verify Deployment

```bash
# Check if the service is running
pm2 status

# Test the API health endpoint
curl http://localhost:3000/health

# Check logs
pm2 logs diceroller-api
```

## Management Commands

### PM2 Process Management
```bash
# Start the service
pm2 start diceroller-api

# Stop the service
pm2 stop diceroller-api

# Restart the service
pm2 restart diceroller-api

# View real-time logs
pm2 logs diceroller-api --lines 50

# Monitor performance
pm2 monit
```

### Service Management
```bash
# Check service status
pm2 status

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup

# Delete a service
pm2 delete diceroller-api
```

## API Endpoints

Once deployed, your API will be available at:

| Endpoint | Description |
|----------|-------------|
| `http://your-vps-ip:3000/` | API root |
| `http://your-vps-ip:3000/health` | Health check |
| `http://your-vps-ip:3000/api/v1/stripe` | Stripe payment routes |
| `http://your-vps-ip:3000/api/v1/apple` | Apple App Store routes |
| `http://your-vps-ip:3000/api/v1/users` | User management |
| `http://your-vps-ip:3000/api/v1/purchases` | Purchase tracking |
| `http://your-vps-ip:3000/api/v1/analytics` | Analytics data |

## Troubleshooting

### Common Issues

1. **Port 3000 is already in use**
   ```bash
   sudo lsof -i :3000
   sudo kill -9 <PID>
   ```

2. **PM2 not found**
   ```bash
   npm install -g pm2
   ```

3. **Permission errors**
   ```bash
   sudo chown -R $USER:$USER /path/to/backend
   ```

4. **Database connection issues**
   ```bash
   # Check PostgreSQL status
   sudo systemctl status postgresql
   
   # Start PostgreSQL
   sudo systemctl start postgresql
   ```

### Logs Location
- PM2 logs: `~/.pm2/logs/`
- Nginx logs: `/var/log/nginx/`
- System logs: `/var/log/syslog`

## Security Considerations

1. **Firewall Configuration**
   ```bash
   # Allow SSH, HTTP, and HTTPS
   sudo ufw allow ssh
   sudo ufw allow http
   sudo ufw allow https
   sudo ufw allow 3000/tcp
   sudo ufw enable
   ```

2. **Regular Updates**
   ```bash
   # Update system packages
   sudo apt update && sudo apt upgrade
   
   # Update Node.js dependencies
   npm audit fix
   ```

3. **Environment Variables**
   - Never commit `.env` files to version control
   - Use strong, unique passwords
   - Rotate JWT secrets regularly

## Backup Strategy

1. **Database Backup** (if using PostgreSQL)
   ```bash
   pg_dump -U username -h localhost diceroller > backup.sql
   ```

2. **Code Backup**
   ```bash
   tar -czf diceroller-backup-$(date +%Y%m%d).tar.gz backend/
   ```

3. **Configuration Backup**
   ```bash
   cp -r backend/.env backend/.env.backup
   ```

## Monitoring

### Real-time Monitoring
```bash
# PM2 monitoring dashboard
pm2 monit

# System resources
htop

# Network connections
netstat -tulpn | grep :3000
```

### Log Analysis
```bash
# Real-time API logs
tail -f ~/.pm2/logs/diceroller-api-out.log

# Error logs
tail -f ~/.pm2/logs/diceroller-api-error.log
```

## Performance Optimization

1. **PM2 Cluster Mode**
   ```bash
   pm2 start ecosystem.config.js --env production
   ```

2. **Nginx Caching**
   ```bash
   # Add to nginx.conf
   location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
       expires 1y;
       add_header Cache-Control "public, immutable";
   }
   ```

3. **Database Optimization**
   - Use connection pooling
   - Optimize queries
   - Regular database maintenance

## Support and Maintenance

- **Updates**: Run `./deploy-to-vps.sh` from your local machine to sync changes
- **Monitoring**: Set up alerts for service downtime
- **Backups**: Schedule regular backups
- **Security**: Keep all packages updated

## Quick Reference

```bash
# Connect to VPS
ssh root@145.223.22.7

# Navigate to backend
cd /root/tiation-github/DiceRollerSimulator/backend

# Start service
pm2 start ecosystem.config.js

# Check status
pm2 status

# View logs
pm2 logs diceroller-api

# Test API
curl http://localhost:3000/health
```

---

**Enterprise-Grade Deployment** ✨ with Dark Neon Theme Support 🌙

For support, check the `DEPLOYMENT.md` file in the backend directory or contact tiatheone@protonmail.com.
