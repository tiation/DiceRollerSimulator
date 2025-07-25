# tiation-dice-roller-ios

![CI/CD](https://github.com/tiation/tiation-dice-roller-ios/workflows/CI/badge.svg)
![Security](https://github.com/tiation/tiation-dice-roller-ios/workflows/Security%20Scan/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Enterprise-grade application with automated CI/CD pipeline and multi-environment deployment.

<img width="1179" height="2556" alt="DMscreenshot" src="https://github.com/user-attachments/assets/c0ee156f-476c-4784-ba07-dc30dabf3a48" />

## 🚀 Features

- **Enterprise CI/CD**: Automated testing, building, and deployment
- **Security First**: Vulnerability scanning and security hardening  
- **Multi-Environment**: Staging and production deployments
- **Container-Ready**: Docker containerization with multi-arch builds
- **Monitoring**: Integrated with Grafana and alerting systems

<img width="1179" height="2556" alt="general-diceroller" src="https://github.com/user-attachments/assets/71a78534-8036-4d46-ac79-3dd8eb8715dc" />

## 🏗️ Architecture

- **Staging**: docker.tiation.net (145.223.22.9)
- **Production**: docker.sxc.codes (145.223.22.7)
- **Helm Charts**: helm.sxc.codes (145.223.21.248)
- **Monitoring**: grafana.sxc.codes (153.92.214.1)

## 📋 Development

<img width="1179" height="2556" alt="roll-chronicle" src="https://github.com/user-attachments/assets/0622c38b-a0fe-4792-971e-e1fa5c3c6fe6" />

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

<img width="1179" height="2556" alt="player-screen" src="https://github.com/user-attachments/assets/fe77c0f9-d1a2-43a9-bd76-6b5d099a8c68" />

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

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-07-26 at 00 00 22" src="https://github.com/user-attachments/assets/9d35cc23-8a5d-4c93-b2ae-1f32e8fb06e2" />

- **Logs**: Aggregated in ELK Stack (elastic.sxc.codes)
- **Metrics**: Grafana dashboards (grafana.sxc.codes)
- **Alerts**: Email and Slack notifications
- **Health Checks**: Automated endpoint monitoring

## 📬 Support & Contact

- **Email**: tiatheone@protonmail.com, garrett@sxc.codes
- **Issues**: GitHub Issues
- **Documentation**: See `docs/` directory

## 📄 License

<img width="1179" height="2556" alt="Simulator Screenshot - iPhone 16 - 2025-07-26 at 00 00 15" src="https://github.com/user-attachments/assets/2d9fbdd1-7f2c-411a-a05d-8d5ee4775b35" />

MIT License - see [LICENSE](LICENSE) file for details.

---

**Enterprise Infrastructure by Tiation** 🌟
