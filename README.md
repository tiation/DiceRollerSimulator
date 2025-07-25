# 🧙‍♂️ Tiation Dice Roller iOS

![CI/CD](https://github.com/tiation/tiation-dice-roller-ios/workflows/CI/badge.svg)
![Security](https://github.com/tiation/tiation-dice-roller-ios/workflows/Security%20Scan/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

An **epic, minimalist dice-rolling app** for iOS, forged in the style of **Lord of the Rings**, designed for real **Dungeons & Dragons adventurers**. Powered by modern DevOps, security-first engineering, and fantasy-fueled UI.

---

<div align="center">
  <img src="https://github.com/user-attachments/assets/c0ee156f-476c-4784-ba07-dc30dabf3a48" alt="DM Screen" width="300" />
  <img src="https://github.com/user-attachments/assets/71a78534-8036-4d46-ac79-3dd8eb8715dc" alt="General Dice Roller" width="300" />
</div>

---

## 🚀 Features

- ⚙️ **Enterprise CI/CD**: Automated testing, building, and deployment
- 🛡️ **Security First**: Vulnerability scanning and hardened builds  
- 🌐 **Multi-Environment**: Staging and production deploy flows
- 🐳 **Container-Ready**: Docker-based with multi-arch support
- 📈 **Monitoring**: Integrated with Grafana and ELK for logs/alerts

---

## 🧱 Architecture Overview

| Environment | Address             | Description                |
|-------------|----------------------|----------------------------|
| Staging     | `docker.tiation.net` | Dev environment            |
| Production  | `docker.sxc.codes`   | Live deployment            |
| Helm        | `helm.sxc.codes`     | Deployment configuration   |
| Monitoring  | `grafana.sxc.codes`  | Metrics and dashboarding   |

---

## 🛠️ Local Development

<div align="center"> <img src="https://github.com/user-attachments/assets/2d9fbdd1-7f2c-411a-a05d-8d5ee4775b35" alt="Simulator Screenshot 1" width="220" /> <img src="https://github.com/user-attachments/assets/c0ee156f-476c-4784-ba07-dc30dabf3a48" alt="DM Screen" width="220" /> <img src="https://github.com/user-attachments/assets/71a78534-8036-4d46-ac79-3dd8eb8715dc" alt="General Dice Roller" width="220" /> <img src="https://github.com/user-attachments/assets/fe77c0f9-d1a2-43a9-bd76-6b5d099a8c68" alt="Player Screen" width="220" /> </div>

### Prerequisites

- Node.js 18+
- Docker
- Git

### Setup

```bash
git clone https://github.com/tiation/tiation-dice-roller-ios.git
cd tiation-dice-roller-ios
npm install
