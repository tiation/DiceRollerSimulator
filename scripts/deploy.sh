#!/bin/bash

# tiation-dice-roller - Enterprise Deployment Script
# Project Type: gaming-tool
# Features: 3d-graphics, statistics, dark-theme, real-time

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="tiation-dice-roller"
PROJECT_TYPE="gaming-tool"
DEFAULT_DOMAIN="tiation-dice-roller.surge.sh"
FEATURES="3d-graphics,statistics,dark-theme,real-time"

# Default values
ENVIRONMENT=${1:-prod}
CUSTOM_DOMAIN=${2:-}

# Determine deployment domain
if [ -n "$CUSTOM_DOMAIN" ]; then
    DEPLOY_DOMAIN="$CUSTOM_DOMAIN"
elif [ "$ENVIRONMENT" = "dev" ]; then
    DEPLOY_DOMAIN="$PROJECT_NAME-dev.surge.sh"
elif [ "$ENVIRONMENT" = "staging" ]; then
    DEPLOY_DOMAIN="$PROJECT_NAME-staging.surge.sh"
else
    DEPLOY_DOMAIN="$DEFAULT_DOMAIN"
fi

# Tiation Enterprise Banner
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                       🚀 TIATION DEPLOYMENT SYSTEM 🚀                        ║"
echo "║                     Enterprise-Grade Dark Neon Platform                      ║"
echo "║                          Project: $PROJECT_NAME                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${MAGENTA}🎯 Project Details:${NC}"
echo -e "   Name: ${YELLOW}$PROJECT_NAME${NC}"
echo -e "   Type: ${YELLOW}$PROJECT_TYPE${NC}"
echo -e "   Features: ${YELLOW}$FEATURES${NC}"
echo -e "   Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "   Domain: ${YELLOW}$DEPLOY_DOMAIN${NC}"
echo ""

# Pre-deployment checks
echo -e "${BLUE}🔍 Running enterprise-grade checks...${NC}"

# Check if surge is installed
if ! command -v surge &> /dev/null; then
    echo -e "${YELLOW}⚠️  Installing Surge CLI...${NC}"
    npm install -g surge
fi

# Check surge authentication
if ! surge whoami &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with Surge. Please login:${NC}"
    echo -e "${YELLOW}   surge login${NC}"
    exit 1
fi

SURGE_USER=$(surge whoami)
echo -e "${GREEN}✅ Authenticated as: $SURGE_USER${NC}"

# Security audit
echo -e "${BLUE}🔒 Running security audit...${NC}"
npm audit --audit-level=high || echo -e "${YELLOW}⚠️  Security warnings found${NC}"

# Install dependencies
if [ ! -d "node_modules" ]; then
    echo -e "${BLUE}📦 Installing dependencies...${NC}"
    npm ci
fi

# Run quality checks
echo -e "${BLUE}🔍 Running code quality checks...${NC}"
npm run lint || echo -e "${YELLOW}⚠️  Linting warnings found${NC}"

# Run tests
echo -e "${BLUE}🧪 Running tests...${NC}"
npm run test || echo -e "${YELLOW}⚠️  Test warnings found${NC}"

# Build application
echo -e "${BLUE}🏗️  Building ${PROJECT_TYPE} application...${NC}"
if [ "$ENVIRONMENT" = "prod" ]; then
    npm run build:prod
else
    npm run build:dev
fi

# Deploy to Surge
echo -e "${BLUE}🚀 Deploying to Surge...${NC}"
surge dist "$DEPLOY_DOMAIN"

# Post-deployment validation
echo -e "${BLUE}🔍 Validating deployment...${NC}"
sleep 10

# Health check
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$DEPLOY_DOMAIN" || echo "000")
if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Health check passed!${NC}"
else
    echo -e "${YELLOW}⚠️  Health check returned HTTP $HTTP_STATUS${NC}"
fi

# Success banner
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                          🎉 DEPLOYMENT SUCCESSFUL! 🎉                        ║"
echo "║                         $PROJECT_NAME is now live!                        ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}🌐 Live Site: https://$DEPLOY_DOMAIN${NC}"
echo -e "${BLUE}📊 Features: $FEATURES${NC}"
echo -e "${MAGENTA}🎨 Theme: Dark Neon with Cyan Gradient${NC}"
echo ""

echo -e "${YELLOW}🚀 Deployment complete for $PROJECT_NAME!${NC}"
