# 🎲 Dice Of Middle-Earth - iOS Dice Roller Functions & Excellence

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

<div align="center"> <img src="https://github.com/user-attachments/assets/2d9fbdd1-7f2c-411a-a05d-8d5ee4775b35" alt="Simulator Screenshot 1" width="220" /> <img src="https://github.com/user-attachments/assets/c0ee156f-476c-4784-ba07-dc30dabf3a48" alt="DM Screen" width="220" /><img src="https://github.com/user-attachments/assets/fe77c0f9-d1a2-43a9-bd76-6b5d099a8c68" alt="Player Screen" width="220" /> </div>

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

---

## 🎮 Gaming-Optimized Design
### 🌟 Core Functions

### 🎭 Dual Role-Based Experience

* ⚔️ **Player Mode**: Hero-themed red interface for D\&D players
* 🧙‍♂️ **Dungeon Master Mode**: Mystical purple interface for DMs
* 🎛️ 25 Custom Dice Slots per role with full personalization
* 🧾 Role-Specific Terminology: *"Hero Rolls"* vs *"Fate Rolls"*

---

### 🎲 Advanced Dice System

* 🎲 **Complete D\&D Dice Set**: d4, d6, d8, d10, d12, d20, d100 + custom dice
* 🔁 **Multiple Roll Types**: Normal, Advantage, Disadvantage, Damage, Healing, Initiative, Ability Check, Saving Throw, Attack Roll
* ➕ **Smart Modifiers**: -10 to +10 with visual feedback
* 🌀 **Animated Rolling**: Smooth physics-based dice animations with sound

---

### 📊 Comprehensive Data Management

* 🕒 **Persistent Roll History**: Last 100 rolls stored with timestamps
* 📜 **Roll Chronicle**: Full log of dice activity across modes
* 🎛️ **General Dice Roller**: Quick access to standard combos
* 🔄 **Cross-Tab Integration**: Shared history system across Player & DM roles

---

### 🎨 Premium User Experience

* 🧝‍♂️ **Lord of the Rings Theming**: Rich fantasy-inspired visuals
* 🍎 **SwiftUI Native**: Modern iOS interface with fluid transitions
* 🌗 **Dark/Light Mode**: Auto-adjusts with system preferences
* 📳 **Haptic Feedback**: Tactile feedback for immersion

---

## 🏆 Why It's The Best Dice Roller

### 🎯 Enterprise-Grade Quality

* 🧱 **Professional Architecture**: MVVM pattern with `ObservableObject`
* 🧼 **Clean Codebase**: Clear separation of concerns
* 📚 **DevOps Ready**: Modular, documented, scalable
* 🎨 **Striking Design**: Bold fantasy UI that remains functional

---

### ♿ Accessibility Excellence

* ✅ **WCAG Compliant**: Full VoiceOver + high contrast text
* 🧩 **Universal Design**: Inclusive for all abilities
* 🔠 **Dynamic Type Support**: Honors system text size
* 🧪 **Thoroughly Tested**: Screen readers, motion toggles, voice control

---

## 🔧 Technical Superiority

### 🚀 Advanced Features

* ⚙️ 24+ Pre-configured Rolls: Attack, Save, Initiative, and more
* 🧱 **Custom Roll Builder**: Unlimited combinations
* 🏪 **Store System**: Magical item upgrades (in-app)
* 📱 **Multi-Device Ready**: Optimized for iPhone and iPad

---

### 💾 Smart Data Handling


```swift
// Automatic roll logging with intelligent storage
func addRoll(_ roll: DiceRoll) {
    rolls.insert(roll, at: 0)
    if rolls.count > 100 {
        rolls = Array(rolls.prefix(100)) // Smart memory management
    }
    saveRolls() // Persistent storage
}

```
---
### 👥 Player-Centric Features

* ⚡ **Instant Results**: Immediate roll outcome
* 📊 **Visual History**: Color-coded + icons by roll type
* 🛡️ **Campaign-Ready**: Suited for live or virtual play
* 🤳 **One-Hand Use**: Designed for mobile gameplay

---

### 🧙‍♂️ DM-Specific Tools

* 🧭 **Advanced UI Options**: Configure complex encounters
* 🌀 **Fate Roll System**: Unique DM terminology and theming
* 📂 **Campaign Management**: Organize by session or encounter

---

## 🚀 Performance & Reliability

* ✅ **iOS 14+ Compatible**: Modern Swift 5.5+
* 📦 **Lightweight**: \~50MB app footprint
* 🌐 **Offline First**: No connection needed
* 🧠 **Efficient Memory Use**: 100-roll smart limit

---

## 🎨 Immersive Experience

* 🌌 **Fantasy Theming**: Deep Middle-Earth inspiration
* 🔊 **Sound Design**: Authentic dice audio
* 🌀 **Animated Feedback**: Realistic physics for rolls
* 🧝‍♂️ **Thematic Cohesion**: Unified fantasy UX

---

## 🌟 What Makes It Superior

1. 🎭 **Role-Based UX**: Player vs DM personalization
2. 🎨 **Immersive Fantasy Theme**: More than utility — it’s a world
3. ♿ **Accessibility First**: Built-in, not bolted-on
4. 📊 **Smart Roll Logging**: Context-aware history
5. 🎯 **Optimized for D\&D**: Real table needs, real solutions
6. 🔧 **Extensible Design**: Room to grow with in-app economy

---

> **Dice Of Middle-Earth** isn’t just a dice roller —
> it’s a complete digital companion that marries technical excellence with the immersive soul of tabletop gaming.

---

