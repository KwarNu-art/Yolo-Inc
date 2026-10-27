# ❄️ GCOOL: Native iOS Gaming & Thermal Companion

[![Build and Test](https://github.com/KwarNu-art/Yolo-Inc/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/KwarNu-art/Yolo-Inc/actions)
[![Package IPA](https://github.com/KwarNu-art/Yolo-Inc/actions/workflows/package-ipa.yml/badge.svg)](https://github.com/KwarNu-art/Yolo-Inc/actions)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://apple.com)
[![Target](https://img.shields.io/badge/Target-iPhone%207%20Plus%20(A10)-orange.svg)](https://apple.com)
[![Display](https://img.shields.io/badge/Display-Retina%20HD%20(60%20Hz)-brightgreen.svg)](https://apple.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> **GCOOL** is a native iOS gaming companion and thermal pressure monitor engineered specifically for the **Apple A10 Fusion** SoC (**iPhone 7 Plus**, arm64, fixed 60 Hz display) running the **iOS 15 family (iOS 15.0 – 15.8.x)**. Built with SwiftUI and UIKit interoperability, GCOOL pairs a premium winter glacier aesthetic with uncompromising technical transparency.

---

## 🌟 Core Philosophy & Technical Honesty

In mobile gaming utilities, users are frequently subjected to fake "RAM booster" animations, fabricated temperatures, and promises of system overclocking that are impossible under the iOS sandbox. GCOOL rejects marketing myths and provides verifiable hardware telemetry:

1. **Honest Thermal Monitoring**: Tracks Apple's official `ProcessInfo.processInfo.thermalState` (Nominal, Fair, Serious, Critical). No fake Celsius readings; third-party sandboxed apps have no kernel access to raw thermistor registers.
2. **Accurate Wall-Clock Session Timing**: Standard iOS suspends apps opportunistically when you switch to a game. GCOOL persists exact timestamps upon departure and return, calculating true elapsed match duration without fabricating synthetic background telemetry.
3. **Transparent Gaming Mode "Lock" Semantics**:
   - **In-App Pinning**: Designating a target game inside GCOOL's UI to measure match duration and thermal changes.
   - **Screen Time Distraction Shield**: Disclosing that individual self-authorization (`AuthorizationCenter.shared.requestAuthorization(for: .individual)`) was introduced in **iOS 16.0+** and is unavailable on the iPhone 7 Plus (which is capped at iOS 15.8.x).
   - **Hardware Single-App Lockdown**: Disclosing that no third-party app can programmatically trap the user in another app; guiding users to Apple's built-in **Guided Access** (triple-click Home Button).
4. **Winter Glacier Aesthetic**: A high-contrast dark midnight navy and crystalline ice-blue visual system with lightweight, battery-conscious Canvas snowfall that automatically pauses when Low Power Mode or Reduce Motion is active.

---

## 📱 Feature Overview

### 1. 📊 Hardware Dashboard
- Live `ProcessInfo.ThermalState` badge and actionable guidance.
- Battery percentage, charging thermal warning, and Low Power Mode detection.
- Pinned active game card with 1-tap launch via custom URL schemes.

### 2. 🎮 User-Curated Game Catalog
- Clean favorites catalog pre-populated with popular titles (*Mobile Legends: Bang Bang*, *PUBG Mobile*, *Call of Duty: Mobile*, *Genshin Impact*, *Subway Surfers*).
- Support for adding custom titles with validated launch schemes (e.g. `pubgmobile://`, `mobilelegends://`).
- Active game pinning for dedicated session telemetry.

### 3. ⏱️ Gaming Session Hub
- Large live wall-clock timer display.
- Peak thermal state observation tracking during match play.
- In-app focus countdown timer and Do Not Disturb recommendations.
- End-session modal with customizable notes saved to local JSON storage.

### 4. 🌡️ Safe Thermals & Battery Lab
- Detailed breakdown of all 4 Apple thermal pressure levels.
- Safe passive cooling recommendations (removing insulating cases, reducing LCD backlight to 55%, room-air convection).
- Explicit warnings against unsafe myths (avoid placing phones in freezers or using ice packs, which cause fatal condensation damage).
- Rolling in-memory thermal state history.

### 5. 💡 A10 Fusion Optimization Guide
- 7 practical engineering tips tailored for the iPhone 7 Plus hardware architecture.
- Analysis of Low Power Mode frame rate downclocking, background refresh overhead, and APFS flash storage headroom.

### 6. ⚙️ Privacy & Data Management
- Non-sensitive plain text session history export (copyable to clipboard).
- 1-tap history deletion.
- Guided Access visual setup guide.
- Complete technical limitations disclosure matrix.

---

## 🛠️ Tech Stack & Architecture

- **Language**: Swift 5.0
- **Frameworks**: SwiftUI, UIKit, Combine, Foundation
- **Architecture**: MVVM with reactive observable service singletons (`DeviceMonitorService`, `SessionManager`, `FavoritesStore`, `DistractionShieldService`).
- **Persistence**: Atomic local JSON document storage via `FileManager`.
- **Target Device**: iPhone 7 Plus (arm64, 3 GB LPDDR4, 60 Hz Retina HD).
- **Minimum Deployment Target**: iOS 15.0.

---

## 📦 Sideloading & Installation

GCOOL can be packaged as an unsigned IPA or signed for personal use:
1. Download **`GCOOL-v1.0.0-unsigned.ipa`** from [GitHub Actions Artifacts or Releases](https://github.com/KwarNu-art/Yolo-Inc/actions).
2. Install via your preferred tool:
   - **TrollStore** (iOS 15.0–15.4.1 or compatible rootless setups): Install directly with permanent signing.
   - **AltStore / Sideloadly**: Sign using a free Apple ID and deploy to iPhone 7 Plus over USB or Wi-Fi.
   - **Xcode**: Open `GCOOL.xcodeproj`, select your development team, and press **Run** (Cmd+R).
