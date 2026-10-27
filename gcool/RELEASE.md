# 🚀 GCOOL: Release & Distribution Guide

This document describes how to sign, package, and distribute GCOOL for personal use on an iPhone 7 Plus running iOS 15.0–15.8.x.

---

## 📦 Sideloading Options

### 1. Sideloadly / AltStore (Recommended for Unjailbroken Devices)
1. Download **`GCOOL-v1.0.0-unsigned.ipa`** from [GitHub Actions Artifacts or Releases](https://github.com/KwarNu-art/Yolo-Inc/actions).
2. Open Sideloadly or AltServer on your Mac/PC.
3. Connect your iPhone 7 Plus via USB.
4. Drag and drop `GCOOL-v1.0.0-unsigned.ipa` into Sideloadly.
5. Enter your free Apple ID credentials to generate a 7-day personal development certificate.
6. Once installed on your iPhone 7 Plus, navigate to **Settings -> General -> VPN & Device Management**, tap your developer certificate, and select **Trust**.

### 2. TrollStore (iOS 15.0 – 15.4.1 / CoreTrust Bug)
If your iPhone 7 Plus is running an iOS 15 build vulnerable to the CoreTrust bug (e.g. iOS 15.0–15.4.1 or installed via Palera1n/Dopamine):
1. Open TrollStore.
2. Tap the `+` button and select `GCOOL-v1.0.0-unsigned.ipa`.
3. Tap **Install**. TrollStore will apply a root fakesign, allowing GCOOL to run indefinitely without 7-day revocations.

### 3. Direct Xcode Deployment
1. Open `GCOOL.xcodeproj` in Xcode on macOS.
2. Connect your iPhone 7 Plus.
3. In the project settings, select your Personal Team under **Signing & Capabilities**.
4. Select your connected iPhone 7 Plus as the build destination.
5. Press **Run (Cmd+R)** to build, install, and attach the debugger.

---

## 🔐 GitHub Secrets for Automated Signing (Optional)

If you have a paid Apple Developer Account and wish to automate signed IPA generation in GitHub Actions, configure the following repository secrets:
- `APPLE_CERTIFICATE_BASE64`: Base64-encoded `.p12` distribution certificate.
- `APPLE_CERTIFICATE_PASSWORD`: Password for the `.p12` certificate.
- `PROVISIONING_PROFILE_BASE64`: Base64-encoded `.mobileprovision` profile matching bundle ID `com.gcool.inc`.
- `KEYCHAIN_PASSWORD`: Temporary password for the CI runner keychain.
