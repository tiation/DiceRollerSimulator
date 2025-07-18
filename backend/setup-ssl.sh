#!/bin/bash
# SSL/HTTPS Setup Script for DiceRollerSimulator Backend
# Sets up Let's Encrypt SSL certificates and HTTPS configuration

set -e

# Configuration
VPS_IP="145.223.22.7"
VPS_USER="root"
DOMAIN="api.dicerollersimulator.com"
EMAIL="tiatheone@protonmail.com"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🔒 DiceRollerSimulator SSL/HTTPS Setup${NC}"
echo -e "${CYAN}=====================================${NC}"
echo -e "${BLUE}Domain: ${DOMAIN}${NC}"
echo -e "${BLUE}VPS: ${VPS_IP}${NC}"
echo -e "${BLUE}Email: ${EMAIL}${NC}"
echo ""

# Check if domain resolves to VPS IP
echo -e "${YELLOW}🔍 Checking DNS resolution...${NC}"
RESOLVED_IP=$(dig +short ${DOMAIN} 2>/dev/null | tail -n1)
if [ "$RESOLVED_IP" != "$VPS_IP" ]; then
    echo -e "${RED}❌ Domain ${DOMAIN} does not resolve to ${VPS_IP}${NC}"
    echo -e "${YELLOW}Current resolution: ${RESOLVED_IP}${NC}"
    echo -e "${YELLOW}Please update your DNS records to point ${DOMAIN} to ${VPS_IP}${NC}"
    echo -e "${YELLOW}You can continue anyway, but SSL certificate generation will fail.${NC}"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo -e "${GREEN}✅ DNS resolution correct${NC}"
fi

# Check VPS connection
echo -e "${YELLOW}🔍 Checking VPS connection...${NC}"
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes ${VPS_USER}@${VPS_IP} exit 2>/dev/null; then
    echo -e "${RED}❌ Cannot connect to VPS ${VPS_IP}${NC}"
    exit 1
fi
echo -e "${GREEN}✅ VPS connection successful${NC}"

# Install Certbot and obtain SSL certificate
echo -e "${YELLOW}🔧 Installing Certbot and setting up SSL...${NC}"
ssh ${VPS_USER}@${VPS_IP} << EOF
# Update package list
apt-get update

# Install Certbot
apt-get install -y certbot python3-certbot-nginx

# Stop nginx temporarily
systemctl stop nginx

# Obtain SSL certificate
certbot certonly --standalone -d ${DOMAIN} --non-interactive --agree-tos --email ${EMAIL}

# Start nginx
systemctl start nginx

echo "✅ SSL certificate obtained"
EOF

# Update Nginx configuration for HTTPS
echo -e "${YELLOW}🌐 Updating Nginx configuration for HTTPS...${NC}"
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
# Create HTTPS Nginx configuration
cat > /etc/nginx/sites-available/dicerollersimulator-api << 'EOL'
# HTTP to HTTPS redirect
server {
    listen 80;
    server_name api.dicerollersimulator.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS configuration
server {
    listen 443 ssl http2;
    server_name api.dicerollersimulator.com;

    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/api.dicerollersimulator.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.dicerollersimulator.com/privkey.pem;
    
    # SSL security settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    ssl_stapling on;
    ssl_stapling_verify on;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self' data:; connect-src 'self' https:;" always;

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
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_cache_bypass $http_upgrade;
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        proxy_redirect off;
        
        # Additional security headers for API
        add_header X-API-Version "v1" always;
        add_header Access-Control-Allow-Origin "https://dicerollersimulator.com" always;
        add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS" always;
        add_header Access-Control-Allow-Headers "Content-Type, Authorization, X-Requested-With" always;
    }

    # Health check endpoint (no rate limiting)
    location /health {
        proxy_pass http://127.0.0.1:3000/health;
        access_log off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Webhook endpoints (special handling)
    location /api/v1/stripe/webhook {
        proxy_pass http://127.0.0.1:3000/api/v1/stripe/webhook;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
        client_max_body_size 1M;
    }

    location /api/v1/apple/webhook {
        proxy_pass http://127.0.0.1:3000/api/v1/apple/webhook;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 60s;
        client_max_body_size 1M;
    }

    # Robots.txt
    location = /robots.txt {
        add_header Content-Type text/plain;
        return 200 "User-agent: *\nDisallow: /\n";
    }

    # Security.txt
    location = /.well-known/security.txt {
        add_header Content-Type text/plain;
        return 200 "Contact: mailto:security@dicerollersimulator.com\nExpires: 2025-12-31T23:59:59.000Z\nCanonical: https://api.dicerollersimulator.com/.well-known/security.txt\n";
    }

    # Logging
    access_log /var/log/nginx/dicerollersimulator-api.access.log;
    error_log /var/log/nginx/dicerollersimulator-api.error.log;
}
EOL

# Test and reload Nginx
nginx -t && systemctl reload nginx

echo "✅ HTTPS configuration updated"
EOF

# Setup automatic certificate renewal
echo -e "${YELLOW}🔄 Setting up automatic SSL certificate renewal...${NC}"
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
# Create renewal hook script
cat > /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh << 'EOL'
#!/bin/bash
systemctl reload nginx
EOL

chmod +x /etc/letsencrypt/renewal-hooks/deploy/reload-nginx.sh

# Test renewal (dry run)
certbot renew --dry-run

# Add to crontab for automatic renewal
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/certbot renew --quiet") | crontab -

echo "✅ Automatic renewal configured"
EOF

# Update firewall for HTTPS
echo -e "${YELLOW}🔒 Updating firewall for HTTPS...${NC}"
ssh ${VPS_USER}@${VPS_IP} << 'EOF'
# Allow HTTPS traffic
ufw allow 443/tcp

# Show firewall status
ufw status

echo "✅ Firewall updated for HTTPS"
EOF

# Test HTTPS setup
echo -e "${YELLOW}🧪 Testing HTTPS setup...${NC}"
echo -e "${BLUE}Testing HTTPS health endpoint...${NC}"
if curl -s "https://${DOMAIN}/health" | grep -q "healthy"; then
    echo -e "${GREEN}✅ HTTPS health check passed${NC}"
else
    echo -e "${RED}❌ HTTPS health check failed${NC}"
fi

echo -e "${BLUE}Testing HTTPS API root endpoint...${NC}"
if curl -s "https://${DOMAIN}/" | grep -q "DiceRollerSimulator API"; then
    echo -e "${GREEN}✅ HTTPS API root endpoint working${NC}"
else
    echo -e "${RED}❌ HTTPS API root endpoint failed${NC}"
fi

echo -e "${BLUE}Testing HTTP to HTTPS redirect...${NC}"
if curl -s -I "http://${DOMAIN}/" | grep -q "301"; then
    echo -e "${GREEN}✅ HTTP to HTTPS redirect working${NC}"
else
    echo -e "${RED}❌ HTTP to HTTPS redirect failed${NC}"
fi

echo -e "${BLUE}Testing SSL certificate...${NC}"
if openssl s_client -connect ${DOMAIN}:443 -servername ${DOMAIN} < /dev/null 2>/dev/null | grep -q "Verify return code: 0"; then
    echo -e "${GREEN}✅ SSL certificate valid${NC}"
else
    echo -e "${RED}❌ SSL certificate validation failed${NC}"
fi

echo ""
echo -e "${GREEN}🎉 SSL/HTTPS Setup Complete!${NC}"
echo -e "${CYAN}=================================${NC}"
echo -e "${BLUE}HTTPS URL: https://${DOMAIN}${NC}"
echo -e "${BLUE}Health Check: https://${DOMAIN}/health${NC}"
echo -e "${BLUE}API Documentation: https://${DOMAIN}/api/v1/docs${NC}"
echo ""
echo -e "${YELLOW}📝 SSL Certificate Details:${NC}"
echo -e "• Certificate expires in ~90 days"
echo -e "• Automatic renewal configured via cron job"
echo -e "• Renewal runs daily at 3 AM"
echo -e "• Nginx automatically reloads on certificate renewal"
echo ""
echo -e "${YELLOW}🔒 Security Features Enabled:${NC}"
echo -e "• TLS 1.2 and 1.3 only"
echo -e "• HTTP Strict Transport Security (HSTS)"
echo -e "• Security headers (CSP, XSS protection, etc.)"
echo -e "• Rate limiting"
echo -e "• HTTP to HTTPS redirect"
echo ""
echo -e "${YELLOW}🧪 Test Your Setup:${NC}"
echo -e "• curl https://${DOMAIN}/health"
echo -e "• curl https://${DOMAIN}/"
echo -e "• SSL Labs test: https://www.ssllabs.com/ssltest/analyze.html?d=${DOMAIN}"
echo ""
echo -e "${YELLOW}🔧 Certificate Management:${NC}"
echo -e "• Check status: ssh ${VPS_USER}@${VPS_IP} 'certbot certificates'"
echo -e "• Renew manually: ssh ${VPS_USER}@${VPS_IP} 'certbot renew'"
echo -e "• Test renewal: ssh ${VPS_USER}@${VPS_IP} 'certbot renew --dry-run'"
echo ""
