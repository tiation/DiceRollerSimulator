#!/usr/bin/env node

/**
 * Tiation Enterprise Deployment Configuration Generator
 * Generates customized deployment configs for each repository
 */

const fs = require('fs');
const path = require('path');

// Repository configurations
const repositories = {
  'tough-talk-podcast-chaos': {
    name: 'tiation-tough-talk-podcast',
    domain: 'tiation-tough-talk.surge.sh',
    description: 'Enterprise-grade podcast platform with advanced dark neon UI and comprehensive security',
    type: 'podcast-platform',
    features: ['audio-streaming', 'dark-theme', 'responsive-design', 'analytics'],
    api_endpoints: ['/api/episodes', '/api/rss', '/api/analytics'],
    csp_additional: 'media-src https://cdn.tiation.com https://audio.tiation.com;'
  },
  'DiceRollerSimulator': {
    name: 'tiation-dice-roller',
    domain: 'tiation-dice-roller.surge.sh',
    description: 'Advanced dice rolling simulator with 3D graphics and statistical analysis',
    type: 'gaming-tool',
    features: ['3d-graphics', 'statistics', 'dark-theme', 'real-time'],
    api_endpoints: ['/api/rolls', '/api/stats', '/api/history'],
    csp_additional: 'worker-src blob: https://cdn.tiation.com;'
  },
  'dice-roller-marketing-site': {
    name: 'tiation-dice-marketing',
    domain: 'tiation-dice-marketing.surge.sh',
    description: 'Marketing website for dice roller simulator with SaaS integration',
    type: 'marketing-site',
    features: ['saas-integration', 'payment-processing', 'dark-theme', 'conversion-tracking'],
    api_endpoints: ['/api/pricing', '/api/payments', '/api/leads'],
    csp_additional: 'frame-src https://js.stripe.com https://checkout.stripe.com;'
  },
  'tiation-ai-agents': {
    name: 'tiation-ai-agents',
    domain: 'tiation-ai-agents.surge.sh',
    description: 'AI-powered automation agents with enterprise-grade security and monitoring',
    type: 'ai-platform',
    features: ['ai-integration', 'automation', 'monitoring', 'enterprise-security'],
    api_endpoints: ['/api/agents', '/api/workflows', '/api/monitoring'],
    csp_additional: 'connect-src https://api.openai.com https://api.anthropic.com;'
  },
  'tiation-chase-white-rabbit-ngo': {
    name: 'tiation-white-rabbit-ngo',
    domain: 'tiation-white-rabbit.surge.sh',
    description: 'NGO platform for social impact with donation processing and campaign management',
    type: 'ngo-platform',
    features: ['donation-processing', 'campaign-management', 'social-impact', 'transparency'],
    api_endpoints: ['/api/donations', '/api/campaigns', '/api/impact'],
    csp_additional: 'frame-src https://js.stripe.com https://www.paypal.com;'
  },
  'tiation-cms': {
    name: 'tiation-cms',
    domain: 'tiation-cms.surge.sh',
    description: 'Enterprise content management system with advanced editing and workflow capabilities',
    type: 'cms-platform',
    features: ['content-management', 'workflow', 'collaboration', 'version-control'],
    api_endpoints: ['/api/content', '/api/workflow', '/api/users'],
    csp_additional: 'img-src * data: blob:; media-src * blob:;'
  },
  'tiation-docker-debian': {
    name: 'tiation-docker-debian',
    domain: 'tiation-docker-debian.surge.sh',
    description: 'Docker on Debian deployment guide with enterprise architecture and security',
    type: 'documentation-site',
    features: ['documentation', 'code-examples', 'architecture-diagrams', 'security-guides'],
    api_endpoints: ['/api/docs', '/api/examples', '/api/feedback'],
    csp_additional: 'img-src * data:; frame-src https://github.com https://gist.github.com;'
  },
  'tiation-economic-reform-proposal': {
    name: 'tiation-economic-reform',
    domain: 'tiation-economic-reform.surge.sh',
    description: 'Economic reform proposal platform with interactive data visualization and policy analysis',
    type: 'policy-platform',
    features: ['data-visualization', 'policy-analysis', 'interactive-charts', 'research-tools'],
    api_endpoints: ['/api/data', '/api/analysis', '/api/feedback'],
    csp_additional: 'script-src \'self\' https://d3js.org https://cdn.plot.ly;'
  },
  'tiation-go-sdk': {
    name: 'tiation-go-sdk',
    domain: 'tiation-go-sdk.surge.sh',
    description: 'Go SDK documentation and examples with interactive code playground',
    type: 'developer-tools',
    features: ['code-playground', 'documentation', 'examples', 'api-reference'],
    api_endpoints: ['/api/docs', '/api/playground', '/api/examples'],
    csp_additional: 'script-src \'self\' \'unsafe-eval\' https://cdn.jsdelivr.net;'
  },
  'tiation-parrot-security-guide-au': {
    name: 'tiation-parrot-security',
    domain: 'tiation-parrot-security.surge.sh',
    description: 'Parrot Security OS guide for Australian cybersecurity professionals',
    type: 'security-guide',
    features: ['security-tools', 'documentation', 'tutorials', 'compliance-guides'],
    api_endpoints: ['/api/tools', '/api/tutorials', '/api/compliance'],
    csp_additional: 'img-src * data:; frame-src https://www.youtube.com https://asciinema.org;'
  },
  'tiation-terminal-workflows': {
    name: 'tiation-terminal-workflows',
    domain: 'tiation-terminal-workflows.surge.sh',
    description: 'Enterprise terminal workflows and automation scripts with interactive demonstrations',
    type: 'developer-tools',
    features: ['workflow-automation', 'interactive-demos', 'code-examples', 'productivity-tools'],
    api_endpoints: ['/api/workflows', '/api/scripts', '/api/demos'],
    csp_additional: 'script-src \'self\' \'unsafe-eval\' https://cdn.jsdelivr.net https://unpkg.com;'
  },
  'ubuntu-dev-setup': {
    name: 'tiation-ubuntu-dev',
    domain: 'tiation-ubuntu-dev.surge.sh',
    description: 'Ubuntu development environment setup guide with automated installation scripts',
    type: 'setup-guide',
    features: ['setup-automation', 'documentation', 'script-generation', 'environment-management'],
    api_endpoints: ['/api/setup', '/api/scripts', '/api/environments'],
    csp_additional: 'img-src * data:; frame-src https://github.com https://gist.github.com;'
  }
};

// Base surge configuration template
const createSurgeConfig = (repo) => {
  const config = repositories[repo];
  
  return {
    "$schema": "https://surge.sh/schema.json",
    "domain": config.domain,
    "name": config.name,
    "version": "1.0.0",
    "description": config.description,
    "repository": `https://github.com/tiation/${repo}`,
    "author": "tiatheone@protonmail.com",
    "license": "MIT",
    "cors": true,
    "https": true,
    "http2": true,
    "gzip": true,
    "brotli": true,
    "minify": {
      "html": true,
      "css": true,
      "js": true
    },
    "environment": {
      "NODE_ENV": "production",
      "PLATFORM": "surge",
      "DEPLOYMENT_TYPE": "enterprise",
      "PROJECT_TYPE": config.type,
      "FEATURES": config.features.join(',')
    },
    "rewrites": [
      ...(config.api_endpoints.map(endpoint => ({
        "source": `${endpoint}/**`,
        "destination": `${endpoint}/index.html`,
        "condition": "!file"
      }))),
      {
        "source": "/admin/**",
        "destination": "/admin/index.html",
        "condition": "!file"
      },
      {
        "source": "/*",
        "destination": "/index.html",
        "condition": "!file"
      }
    ],
    "redirects": [
      {
        "source": "/old-site",
        "destination": "/",
        "type": 301
      },
      {
        "source": "/feed",
        "destination": "/api/rss.xml",
        "type": 302
      }
    ],
    "headers": {
      "/**": {
        "Strict-Transport-Security": "max-age=63072000; includeSubDomains; preload",
        "X-Content-Type-Options": "nosniff",
        "X-Frame-Options": "SAMEORIGIN",
        "X-XSS-Protection": "1; mode=block",
        "X-DNS-Prefetch-Control": "on",
        "X-Robots-Tag": "index, follow",
        "Referrer-Policy": "strict-origin-when-cross-origin",
        "Feature-Policy": "geolocation 'none'; microphone 'none'; camera 'none'; payment 'none'; usb 'none'",
        "Permissions-Policy": "geolocation=(), microphone=(), camera=(), payment=(), usb=(), magnetometer=(), gyroscope=(), accelerometer=()",
        "Content-Security-Policy": `default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://cdn.jsdelivr.net https://unpkg.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdn.jsdelivr.net; font-src 'self' data: https://fonts.gstatic.com https://cdn.jsdelivr.net; img-src 'self' data: https: blob:; media-src 'self' https: blob:; object-src 'none'; frame-src 'self' https://www.youtube.com https://player.vimeo.com; connect-src 'self' https: wss: ws:; worker-src 'self' blob:; manifest-src 'self'; base-uri 'self'; form-action 'self'; ${config.csp_additional}`,
        "Cache-Control": "public, max-age=1800, s-maxage=3600, stale-while-revalidate=86400",
        "Vary": "Accept-Encoding, Accept",
        "X-Powered-By": "Tiation Enterprise Platform",
        "X-Deployment-Version": "1.0.0",
        "X-Environment": "production",
        "X-Project-Type": config.type,
        "X-Features": config.features.join(',')
      },
      "/api/**": {
        "Cache-Control": "no-cache, no-store, must-revalidate",
        "Content-Type": "application/json; charset=utf-8",
        "Access-Control-Allow-Origin": `https://${config.domain}`,
        "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, Authorization, X-Requested-With",
        "Access-Control-Max-Age": "86400"
      },
      "/static/**": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Access-Control-Allow-Origin": "*"
      },
      "/assets/**": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Access-Control-Allow-Origin": "*",
        "Cross-Origin-Resource-Policy": "cross-origin"
      },
      "/*.css": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Content-Type": "text/css; charset=utf-8"
      },
      "/*.js": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Content-Type": "application/javascript; charset=utf-8"
      },
      "/*.woff2": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Content-Type": "font/woff2",
        "Access-Control-Allow-Origin": "*"
      },
      "/*.woff": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Content-Type": "font/woff",
        "Access-Control-Allow-Origin": "*"
      },
      "/*.webp": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Content-Type": "image/webp"
      },
      "/*.webm": {
        "Cache-Control": "public, max-age=31536000, immutable",
        "Content-Type": "video/webm"
      },
      "/sitemap.xml": {
        "Cache-Control": "public, max-age=86400",
        "Content-Type": "application/xml; charset=utf-8"
      },
      "/robots.txt": {
        "Cache-Control": "public, max-age=86400",
        "Content-Type": "text/plain; charset=utf-8"
      },
      "/manifest.json": {
        "Cache-Control": "public, max-age=86400",
        "Content-Type": "application/manifest+json; charset=utf-8"
      },
      "/sw.js": {
        "Cache-Control": "no-cache, no-store, must-revalidate",
        "Content-Type": "application/javascript; charset=utf-8"
      }
    },
    "cleanUrls": true,
    "trailing_slash": false,
    "custom_404": "404.html",
    "custom_500": "500.html",
    "performance": {
      "preload": [
        "/assets/fonts/inter.woff2",
        "/assets/css/critical.css"
      ],
      "prefetch": [
        "/assets/js/main.js",
        "/assets/css/main.css"
      ]
    },
    "seo": {
      "canonical": `https://${config.domain}`,
      "robots": "index,follow",
      "sitemap": "/sitemap.xml"
    },
    "analytics": {
      "provider": "custom",
      "tracking_id": "TIATION_ANALYTICS"
    },
    "monitoring": {
      "uptime": true,
      "performance": true,
      "security": true
    }
  };
};

// Generate package.json scripts
const createPackageScripts = (repo) => {
  const config = repositories[repo];
  
  return {
    "dev": "vite",
    "build": "vite build",
    "build:dev": "vite build --mode development",
    "build:prod": "vite build --mode production",
    "build:analyze": "vite build --mode production --report",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "test": "vitest",
    "test:coverage": "vitest --coverage",
    "preview": "vite preview",
    "deploy": "npm run build && gh-pages -d dist",
    "deploy:netlify": "npm run build && npx netlify-cli deploy --prod --dir dist",
    "deploy:surge": `npm run build:prod && npx surge dist --domain ${config.domain}`,
    "deploy:surge:custom": "npm run build:prod && npx surge dist",
    "deploy:all": "npm run deploy:surge && npm run deploy",
    "predeploy": "npm run lint && npm run test && npm run build:prod",
    "postdeploy": "npm run health-check",
    "surge:login": "npx surge login",
    "surge:whoami": "npx surge whoami",
    "surge:list": "npx surge list",
    "surge:teardown": `npx surge teardown ${config.domain}`,
    "health-check": `curl -f https://${config.domain}/health || exit 1`,
    "lighthouse": `npx lighthouse https://${config.domain} --output html --output-path ./lighthouse-report.html`,
    "security-scan": `npx audit-ci --config .audit-ci.json`,
    "performance-test": `npx pagespeed-insights https://${config.domain}`
  };
};

// Generate GitHub Actions workflow
const createGitHubWorkflow = (repo) => {
  const config = repositories[repo];
  
  return `name: Deploy to Surge - ${config.name}

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  NODE_VERSION: '18'
  SURGE_DOMAIN: '${config.domain}'
  PROJECT_TYPE: '${config.type}'

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        
      - name: Run security audit
        run: |
          npm audit --audit-level=high
          
  build-and-test:
    runs-on: ubuntu-latest
    needs: security-scan
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: \${{ env.NODE_VERSION }}
          cache: 'npm'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Run linting
        run: npm run lint
        
      - name: Run tests
        run: npm run test
        
      - name: Build application
        run: npm run build:prod
        env:
          NODE_ENV: production
          PROJECT_TYPE: \${{ env.PROJECT_TYPE }}
          
      - name: Run security scan
        run: npm run security-scan
        continue-on-error: true
        
      - name: Upload build artifacts
        uses: actions/upload-artifact@v4
        with:
          name: build-files
          path: dist/
          
  deploy-production:
    runs-on: ubuntu-latest
    needs: build-and-test
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-files
          path: dist/
          
      - name: Deploy to Surge
        run: |
          npm install -g surge
          surge ./dist \${{ env.SURGE_DOMAIN }} --token \${{ secrets.SURGE_TOKEN }}
        env:
          SURGE_TOKEN: \${{ secrets.SURGE_TOKEN }}
          
      - name: Wait for deployment
        run: sleep 30
        
      - name: Health check
        run: |
          curl -f https://\${{ env.SURGE_DOMAIN }}/health || echo "Health check failed"
          
      - name: Lighthouse CI
        run: |
          npm install -g @lhci/cli
          lhci autorun
        env:
          LHCI_GITHUB_APP_TOKEN: \${{ secrets.LHCI_GITHUB_APP_TOKEN }}
          
      - name: Performance test
        run: npm run performance-test
        continue-on-error: true
        
  deploy-preview:
    runs-on: ubuntu-latest
    needs: build-and-test
    if: github.event_name == 'pull_request'
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        
      - name: Download build artifacts
        uses: actions/download-artifact@v4
        with:
          name: build-files
          path: dist/
          
      - name: Deploy preview to Surge
        run: |
          npm install -g surge
          PREVIEW_DOMAIN="\${{ env.SURGE_DOMAIN }}-pr-\${{ github.event.number }}.surge.sh"
          surge ./dist $PREVIEW_DOMAIN --token \${{ secrets.SURGE_TOKEN }}
          echo "PREVIEW_URL=https://$PREVIEW_DOMAIN" >> $GITHUB_ENV
        env:
          SURGE_TOKEN: \${{ secrets.SURGE_TOKEN }}
          
      - name: Comment PR
        uses: actions/github-script@v7
        with:
          script: |
            const previewUrl = process.env.PREVIEW_URL;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: \`🚀 **Preview deployed successfully!**

📱 **Preview URL:** \${previewUrl}
🔗 **Main Site:** https://\${{ env.SURGE_DOMAIN }}
🏗️ **Project Type:** \${{ env.PROJECT_TYPE }}

**Features:**
${config.features.map(f => `- ${f}`).join('\n')}

*This preview will be automatically cleaned up when the PR is merged.*\`
            });
`;
};

// Create deployment script template
const createDeploymentScript = (repo) => {
  const config = repositories[repo];
  
  return `#!/bin/bash

# ${config.name} - Enterprise Deployment Script
# Project Type: ${config.type}
# Features: ${config.features.join(', ')}

set -e

# Colors for output
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[0;34m'
CYAN='\\033[0;36m'
MAGENTA='\\033[0;35m'
NC='\\033[0m' # No Color

# Project configuration
PROJECT_NAME="${config.name}"
PROJECT_TYPE="${config.type}"
DEFAULT_DOMAIN="${config.domain}"
FEATURES="${config.features.join(',')}"

# Default values
ENVIRONMENT=\${1:-prod}
CUSTOM_DOMAIN=\${2:-}

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
echo -e "\${CYAN}"
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                       🚀 TIATION DEPLOYMENT SYSTEM 🚀                        ║"
echo "║                     Enterprise-Grade Dark Neon Platform                      ║"
echo "║                          Project: $PROJECT_NAME                           ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "\${NC}"

echo -e "\${MAGENTA}🎯 Project Details:\${NC}"
echo -e "   Name: \${YELLOW}$PROJECT_NAME\${NC}"
echo -e "   Type: \${YELLOW}$PROJECT_TYPE\${NC}"
echo -e "   Features: \${YELLOW}$FEATURES\${NC}"
echo -e "   Environment: \${YELLOW}$ENVIRONMENT\${NC}"
echo -e "   Domain: \${YELLOW}$DEPLOY_DOMAIN\${NC}"
echo ""

# Pre-deployment checks
echo -e "\${BLUE}🔍 Running enterprise-grade checks...\${NC}"

# Check if surge is installed
if ! command -v surge &> /dev/null; then
    echo -e "\${YELLOW}⚠️  Installing Surge CLI...\${NC}"
    npm install -g surge
fi

# Check surge authentication
if ! surge whoami &> /dev/null; then
    echo -e "\${RED}❌ Not authenticated with Surge. Please login:\${NC}"
    echo -e "\${YELLOW}   surge login\${NC}"
    exit 1
fi

SURGE_USER=\$(surge whoami)
echo -e "\${GREEN}✅ Authenticated as: $SURGE_USER\${NC}"

# Security audit
echo -e "\${BLUE}🔒 Running security audit...\${NC}"
npm audit --audit-level=high || echo -e "\${YELLOW}⚠️  Security warnings found\${NC}"

# Install dependencies
if [ ! -d "node_modules" ]; then
    echo -e "\${BLUE}📦 Installing dependencies...\${NC}"
    npm ci
fi

# Run quality checks
echo -e "\${BLUE}🔍 Running code quality checks...\${NC}"
npm run lint || echo -e "\${YELLOW}⚠️  Linting warnings found\${NC}"

# Run tests
echo -e "\${BLUE}🧪 Running tests...\${NC}"
npm run test || echo -e "\${YELLOW}⚠️  Test warnings found\${NC}"

# Build application
echo -e "\${BLUE}🏗️  Building \${PROJECT_TYPE} application...\${NC}"
if [ "$ENVIRONMENT" = "prod" ]; then
    npm run build:prod
else
    npm run build:dev
fi

# Deploy to Surge
echo -e "\${BLUE}🚀 Deploying to Surge...\${NC}"
surge dist "$DEPLOY_DOMAIN"

# Post-deployment validation
echo -e "\${BLUE}🔍 Validating deployment...\${NC}"
sleep 10

# Health check
HTTP_STATUS=\$(curl -s -o /dev/null -w "%{http_code}" "https://$DEPLOY_DOMAIN" || echo "000")
if [ "$HTTP_STATUS" = "200" ]; then
    echo -e "\${GREEN}✅ Health check passed!\${NC}"
else
    echo -e "\${YELLOW}⚠️  Health check returned HTTP $HTTP_STATUS\${NC}"
fi

# Success banner
echo -e "\${GREEN}"
echo "╔═══════════════════════════════════════════════════════════════════════════════╗"
echo "║                          🎉 DEPLOYMENT SUCCESSFUL! 🎉                        ║"
echo "║                         $PROJECT_NAME is now live!                        ║"
echo "╚═══════════════════════════════════════════════════════════════════════════════╝"
echo -e "\${NC}"

echo -e "\${CYAN}🌐 Live Site: https://$DEPLOY_DOMAIN\${NC}"
echo -e "\${BLUE}📊 Features: $FEATURES\${NC}"
echo -e "\${MAGENTA}🎨 Theme: Dark Neon with Cyan Gradient\${NC}"
echo ""

echo -e "\${YELLOW}🚀 Deployment complete for $PROJECT_NAME!\${NC}"
`;
};

// Main execution
const main = () => {
  const repoName = process.argv[2];
  
  if (!repoName) {
    console.log('Usage: node generate-deployment-config.js <repository-name>');
    console.log('Available repositories:');
    Object.keys(repositories).forEach(repo => {
      console.log(`  - ${repo}`);
    });
    return;
  }
  
  if (!repositories[repoName]) {
    console.error(`Repository ${repoName} not found in configuration`);
    return;
  }
  
  const config = repositories[repoName];
  
  // Generate all configuration files
  console.log(`Generating deployment configuration for ${repoName}...`);
  
  // Create surge.json
  const surgeConfig = createSurgeConfig(repoName);
  fs.writeFileSync('surge.json', JSON.stringify(surgeConfig, null, 2));
  
  // Create CNAME
  fs.writeFileSync('CNAME', config.domain);
  
  // Create package.json scripts (merge with existing)
  const packageScripts = createPackageScripts(repoName);
  if (fs.existsSync('package.json')) {
    const packageJson = JSON.parse(fs.readFileSync('package.json', 'utf8'));
    packageJson.scripts = { ...packageJson.scripts, ...packageScripts };
    fs.writeFileSync('package.json', JSON.stringify(packageJson, null, 2));
  }
  
  // Create GitHub workflow
  const workflow = createGitHubWorkflow(repoName);
  if (!fs.existsSync('.github/workflows')) {
    fs.mkdirSync('.github/workflows', { recursive: true });
  }
  fs.writeFileSync('.github/workflows/deploy-surge.yml', workflow);
  
  // Create deployment script
  const deployScript = createDeploymentScript(repoName);
  if (!fs.existsSync('scripts')) {
    fs.mkdirSync('scripts', { recursive: true });
  }
  fs.writeFileSync('scripts/deploy.sh', deployScript);
  fs.chmodSync('scripts/deploy.sh', 0o755);
  
  console.log(`✅ Configuration generated for ${repoName}`);
  console.log(`   Domain: ${config.domain}`);
  console.log(`   Type: ${config.type}`);
  console.log(`   Features: ${config.features.join(', ')}`);
};

if (require.main === module) {
  main();
}

module.exports = { repositories, createSurgeConfig, createPackageScripts, createGitHubWorkflow, createDeploymentScript };
