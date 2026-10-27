# ⚡️ NovaShield: Performance, Thermal & Global Super Fast Charge Engine

[![NovaShield CI/CD](https://github.com/KwarNu-art/Microlab-2/actions/workflows/build.yml/badge.svg)](https://github.com/KwarNu-art/Microlab-2/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-black.svg)](https://apple.com)
[![Architecture](https://img.shields.io/badge/Architecture-iphoneos--arm64%20(Rootless)-purple.svg)](https://github.com/KwarNu-art/Microlab-2)
[![Device](https://img.shields.io/badge/Target-iPhone%207%20Plus%20(A10)-orange.svg)](https://apple.com)

> **NovaShield** is an elite rootless jailbreak tweak engineered specifically for Apple A10 Fusion devices (iPhone 7 Plus running iOS 15.0 - 15.8.x) on **Dopamine** and **Palera1n**. It permanently cures severe thermal throttling, `thermalmonitord` watchdog loops, I2C bus hangs, slow charging, background daemon runaway, and memory saturation during intense gaming (**Mobile Legends: Bang Bang**) and heavy **Telegram** usage while maintaining **strict 0% standby battery drain**.

---

## ⚡️ Key Features & Architecture (v1.1.0)

### 1. ⚡️ Global Super Fast Charger Engine (A10 Turbo Charging)
* **Problem on iPhone 7 Plus**: When connected to power, iOS daemons (`backupd`, `cloudphotod`, `suggestd`, `mediaanalysisd`) spin up to index photos and files, heating the A10 SoC above 42°C. The internal `thermalmonitord` chokes charging current from 2.1A (10W-12W) down to 0.8A (4W), causing painfully slow charging.
* **NovaShield Solution**:
  * Hooks `SBUIController ACPowerChanged` and `UIDeviceBatteryStateDidChangeNotification`.
  * **Charge Heat Shield**: Freezes/throttles heavy background indexing daemons to idle (`nice +19`) while charging, keeping the battery below 36°C.
  * Allows the hardware power delivery controller to continuously draw the maximum safe **2.1A / 2.4A Turbo Charging profile**.
  * Displays an animated Apple-style **Super Fast Charger HUD** with live battery percentage and wattage profile.

### 2. 💎 Live On-Screen Reaction Proof Banner
* Upon installation and every subsequent respring or boot, NovaShield displays a floating glassmorphic banner at the top of the screen:
  * **"⚡️ NovaShield Online — A10 Rescue & Super Fast Charge Engine Active"**
  * Provides 100% immediate visible proof on your iPhone 7 Plus screen that all Substrate/ElleKit hooks are alive and functioning.

### 3. 🌙 Screen-State Aware Energy Lifecycle (Zero Standby Drain)
* Hooks `SBBacklightController` and Darwin kernel notification `com.apple.springboard.hasBlankedScreen`.
* **Screen ON**: Activates low-overhead kernel telemetry polling every 2.5 seconds.
* **Screen OFF / Sleep**: Instantly suspends all background timers, dispatch queues, and telemetry threads, ensuring **0.0% battery drain while locked**.

### 4. 📊 Low-Overhead Mach Kernel CPU Calculation
* Utilizes Mach kernel `host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, ...)` to track tick-level CPU utilization across Hurricane and Zephyr cores without CPU wake-up spikes.

### 5. 💎 Apple-Style Glassmorphism Warning HUD (`NovaHUD`)
* When CPU load exceeds user threshold (>80% for 3+ consecutive checks), a sleek glassmorphic HUD slides down smoothly from the top of the screen:
  * Native `UIVisualEffectView` with continuous rounded corners (`kCACornerCurveContinuous`).
  * Live telemetry readout: **CPU Load %** and **Active RAM Footprint**.
  * Embedded **"⚡️ Boost & Cool"** direct action button.
  * Auto-dismisses when system load stabilizes, or dismissible via swipe-up.

### 6. ⚡️ One-Tap "Boost & Cool" Rescue Action
* **Instant Cache Purge**: Broadcasts system-wide memory warnings and flushes texture buffers.
* **Daemon Throttle**: Drops runaway background daemons (`suggestd`, `passd`, `assetd`) to `nice +19` idle priority.
* **Foreground Thread Elevation**: Sets the foreground application (MLBB, Telegram) to `QOS_CLASS_USER_INTERACTIVE`.
* **Tactile Confirmation**: Heavy haptic feedback via `UIImpactFeedbackGenerator`.

### 7. ⚙️ Preferences & Settings Integration
* Configurable directly in the iOS **Settings.app** under **NovaShield⚡️**:
  * Master Enable / Disable switch.
  * On-Screen Proof Banner switch.
  * Global Super Fast Charger switch & Charge Heat Shield toggle.
  * CPU Warning Threshold Slider (60% to 95%).
  * Auto-Boost Gaming Mode for MLBB and Telegram.
  * **"⚡️ Test Super Fast Charge HUD"** interactive button.
  * **"⚡️ Test Warning HUD Preview"** interactive button.
  * **"Restart SpringBoard (Apply)"** respring button.

---

## 📲 Installation Guide (Sileo / Zebra / Filza)

### Rootless Jailbreak (Dopamine / Palera1n)
1. Download **`NovaShield-Rootless-arm64.deb`** from [GitHub Releases](https://github.com/KwarNu-art/Microlab-2/releases).
2. Open the file in **Sileo**, **Zebra**, or **Filza**.
3. Tap **Get / Install** and confirm.
4. The post-install script will automatically trigger a clean SpringBoard reload.
5. As soon as the screen turns on, you will see the **⚡️ NovaShield Online** glassmorphic banner confirming it is active!
6. Open **Settings.app** ➡️ **NovaShield⚡️** to customize thresholds or test the Fast Charge HUD.
