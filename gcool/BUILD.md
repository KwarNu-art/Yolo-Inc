# 🔨 GCOOL: Build and Compilation Guide

This document describes how to build, test, and package GCOOL from the command line or within Xcode.

---

## 📋 Prerequisites

- **Host Machine**: macOS 13 (Ventura), macOS 14 (Sonoma), or macOS 15 (Sequoia).
- **Xcode Version**: Xcode 15.0 or later (Xcode 15.4 recommended).
- **iOS SDK**: iOS 15.0 or later.
- **Target Device Profile**: iPhone 7 Plus (`iPhone9,2` / `iPhone9,4`), arm64.

---

## 🧪 Running Unit Tests Locally

To run the unit test suite on a local iOS simulator via `xcodebuild`:

```bash
xcodebuild test \
  -project GCOOL.xcodeproj \
  -scheme GCOOL \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO
```

### Verified Test Cases
- `SessionManagerTests`:
  - `testStartAndEndSession`: Validates lifecycle state transitions and history count.
  - `testElapsedDurationCalculation`: Verifies accurate wall-clock time math (45s, 1h 15m).
  - `testThermalObservationTracking`: Confirms peak thermal state retention during sessions.
  - `testClearAllHistory`: Tests local history deletion.
- `DeviceMonitorTests`:
  - `testThermalLevelMapping`: Verifies `ProcessInfo.ThermalState` mapping to `ThermalLevel`.
  - `testThermalLevelTitlesAndBadges`: Verifies UI badge string outputs.
  - `testThermalSnapshotBatteryFormatting`: Tests normal vs unknown (-1.0) battery values.
  - `testThermalExplanationsAvoidDangerousCooling`: Verifies absence of unsafe cooling advice.
- `FavoritesStoreTests`:
  - `testDefaultGamesLoaded`: Confirms default titles.
  - `testAddAndPinGame`: Tests custom game creation and active pinning.
  - `testURLSchemeValidation`: Tests URL scheme parsing.
  - `testDeleteGame`: Tests game deletion.
- `FeasibilityTests`:
  - `testFourLockMeaningsExplicitlyDistinguished`: Confirms the 4 distinct lock meanings.
  - `testScreenTimeFeasibilityStatus`: Tests runtime evaluation of iOS 15 Screen Time limits.

---

## 📦 Building an Unsigned Generic iOS IPA

To build an unsigned device IPA for sideloading (AltStore, Sideloadly, TrollStore):

```bash
# 1. Compile the generic iOS application binary
xcodebuild build \
  -project GCOOL.xcodeproj \
  -scheme GCOOL \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath build/derivedData \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  AD_HOC_CODE_SIGNING_ALLOWED=YES

# 2. Package into Payload structure
mkdir -p Payload
cp -R build/derivedData/Build/Products/Release-iphoneos/GCOOL.app Payload/

# 3. Zip into .ipa archive
zip -qr GCOOL-v1.0.0-unsigned.ipa Payload/

# 4. Generate SHA-256 verification checksum
shasum -a 256 GCOOL-v1.0.0-unsigned.ipa > GCOOL-v1.0.0-unsigned.ipa.sha256
```

---

## ⚙️ Automated GitHub Actions Workflows

- **`.github/workflows/build-and-test.yml`**: Automatically triggered on every push or pull request to validate compilation and run unit tests.
- **`.github/workflows/package-ipa.yml`**: Manually triggered via `workflow_dispatch` (Actions tab -> Run workflow) to assemble `GCOOL-v1.0.0-unsigned.ipa` and publish an official GitHub Release.
