# tiation-dice-roller-ios

![CI/CD](https://github.com/tiation/tiation-dice-roller-ios/workflows/CI/badge.svg)
![Security](https://github.com/tiation/tiation-dice-roller-ios/workflows/Security%20Scan/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Enterprise-grade application with automated CI/CD pipeline and multi-environment deployment.

## 🚀 Features

- **Enterprise CI/CD**: Automated testing, building, and deployment
- **Security First**: Vulnerability scanning and security hardening  
- **Multi-Environment**: Staging and production deployments
- **Container-Ready**: Docker containerization with multi-arch builds
- **Monitoring**: Integrated with Grafana and alerting systems

## 🏗️ Architecture

- **Staging**: docker.tiation.net (145.223.22.9)
- **Production**: docker.sxc.codes (145.223.22.7)
- **Helm Charts**: helm.sxc.codes (145.223.21.248)
- **Monitoring**: grafana.sxc.codes (153.92.214.1)

## 📋 Development

### Prerequisites

- Node.js 18+
- Docker
- Git

### Setup

```bash
git clone https://github.com/tiation/tiation-dice-roller-ios.git
cd tiation-dice-roller-ios
npm install
```

### Running Locally

```bash
npm run dev
```

### Testing

```bash
# Run all tests
npm test

# Run linting
npm run lint

# Run security checks
./scripts/ci-cd/security-check.sh
```

## 🚢 Deployment

### Automatic Deployments

- **Staging**: Triggered on push to `develop` branch
- **Production**: Triggered on push to `main` branch

### Manual Deployment

```bash
# Build Docker image
docker build -t tiation-dice-roller-ios .

# Deploy to staging
./scripts/deploy-staging.sh

# Deploy to production  
./scripts/deploy-production.sh
```

## 🔒 Security

This project follows enterprise security practices:

- Automated vulnerability scanning with Trivy
- Security-focused ESLint rules
- Regular dependency audits
- Non-root container execution
- Secrets management via GitHub Secrets

## 📊 Monitoring & Observability

- **Logs**: Aggregated in ELK Stack (elastic.sxc.codes)
- **Metrics**: Grafana dashboards (grafana.sxc.codes)
- **Alerts**: Email and Slack notifications
- **Health Checks**: Automated endpoint monitoring

## 📬 Support & Contact

- **Email**: tiatheone@protonmail.com, garrett@sxc.codes
- **Issues**: GitHub Issues
- **Documentation**: See `docs/` directory

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

**Enterprise Infrastructure by Tiation** 🌟
