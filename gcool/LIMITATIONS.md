# ⚖️ GCOOL: Technical Limitations & Feasibility Matrix

GCOOL is built upon the principle of **technical honesty**. This document provides an engineering breakdown of what GCOOL can and cannot do under Apple's operating system architecture on the iPhone 7 Plus running iOS 15.0–15.8.x.

---

## 📊 Feasibility Matrix

| Feature | Available on iPhone 7 Plus (iOS 15) | Required API / Entitlement | Signing / Distribution Limitations | Technical Reality & Honest Fallback |
| :--- | :--- | :--- | :--- | :--- |
| **ProcessInfo.ThermalState Monitoring** | **YES** | Public `Foundation` API (`ProcessInfo.processInfo.thermalState`) | Standard App Store / Ad-Hoc / Sideload | Reports Apple's verified kernel thermal pressure levels: Nominal, Fair, Serious, and Critical. **No direct Celsius readings** are exposed by Apple to sandboxed apps. |
| **Wall-Clock Gaming Session Timing** | **YES** | Public `Foundation` (`Date()`, `FileManager`) | Standard App Store / Ad-Hoc / Sideload | Accurately calculates elapsed duration from persisted timestamps upon app departure and return. **No continuous background CPU execution** while the user plays a game. |
| **In-App Game Pinning ("Lock")** | **YES** | Pure Swift / SwiftUI state | Standard App Store / Ad-Hoc / Sideload | Designates the active game in GCOOL's UI to track dedicated session durations, thermal alerts, and match notes. |
| **Personal Screen Time Distraction Blocking** | **NO (iOS 16+ Only)** | `FamilyControls` (`AuthorizationCenter.requestAuthorization(for: .individual)`) | Requires iOS 16.0+ & `com.apple.developer.family-controls` entitlement | On iOS 15, `FamilyControls` was strictly designed for parent-child Family Sharing (`.child`). Self-authorization was introduced in iOS 16. GCOOL provides an honest in-app focus countdown timer instead. |
| **Automatic Installed App Discovery** | **NO (Sandbox Protected)** | Private APIs (`LSApplicationWorkspace`) | Prohibited in App Store sandbox | Sandboxed applications cannot enumerate third-party installed apps. GCOOL provides a user-curated favorites catalog with URL scheme validation. |
| **Forced Single-App Device Lockdown** | **MANUAL ONLY** | Built-in Apple Accessibility Feature | System-level Guided Access | No third-party app can programmatically lock the device into another app. GCOOL provides a step-by-step setup guide for Apple's built-in **Guided Access** (triple-click Home Button). |
| **RAM Cleaning & Process Termination** | **IMPOSSIBLE IN SOFTWARE** | Kernel Jetsam Subsystem | Strictly reserved for XNU Kernel | Sandboxed apps cannot force-close other apps or freeze memory allocations. Memory management is handled by Apple's Jetsam daemon. GCOOL offers practical advice to disable Background App Refresh in iOS Settings. |
| **CPU / GPU Overclocking** | **IMPOSSIBLE IN SOFTWARE** | Hardware Power Management (PMU) | Managed by Apple firmware | Third-party apps cannot increase hardware clock frequencies. The iPhone 7 Plus display is fixed at 60 Hz; games will render at up to 60 FPS depending on scene complexity. |

---

## 🔒 The 4 Meanings of "Lock" in GCOOL

To prevent user confusion, GCOOL explicitly distinguishes between four common meanings of "lock":

1. **In-App Pinning ("Locking" the active session)**: Selecting a game from the catalog as the active focus in GCOOL. Supported natively.
2. **Distraction Shield ("Locking" other apps)**: Blocking social media notifications via Screen Time. On iOS 15, individual self-authorization is not supported by Apple.
3. **RAM Freezing ("Locking" the game in memory)**: Preventing iOS from terminating a game in the background. Technically impossible in the iOS sandbox.
4. **Single-App Kiosk ("Locking" the screen into the game)**: Preventing accidental home swipes or notification center pull-downs. Achieved via Apple's built-in **Guided Access** feature.
