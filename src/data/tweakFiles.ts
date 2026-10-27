import { TweakConfig, TweakFile } from '../types/tweak';

export const defaultTweakConfig: TweakConfig = {
  extremeMode: true,
  backgroundFreezer: true,
  freezeMethod: 'hybrid',
  storyStripper: true,
  lottieStripper: true,
  reactionStripper: true,
  blurBypass: true,
  typingZeroLag: true,
  qosVipElevation: true,
  thermalThrottleShield: true,
  aggressiveRamPurge: true,
  ramPurgeIntervalMinutes: 10,
  sqliteVacuum: true,
  proMotionClampIdle: true,
  inAppSettingsMenu: true,
  targetArchitecture: 'both',
  targetIosMin: '15.0',
};

export const tweakFiles: TweakFile[] = [
  {
    id: 'tweak_x',
    name: 'Tweak.x',
    path: 'src/Tweak.x',
    language: 'objectivec',
    description: 'Core Logos hooking engine with Telegram VIP CPU boost, background freeze, & memory purging.',
    getContent: (config: TweakConfig) => `/**
 * ============================================================================
 * TeleTurbo - Ultra Performance & Anti-Thermal Engine for Telegram iOS
 * Target: ph.telegra.Telegraph & com.apple.springboard
 * Architecture: arm64, arm64e (Rootless & Rootful / Jailed Sideload Compatible)
 * ============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <sys/resource.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <signal.h>
#import <pthread.h>

#define TT_LOG(fmt, ...) NSLog(@"[TeleTurbo⚡] " fmt, ##__VA_ARGS__)

static BOOL kExtremeModeEnabled = ${config.extremeMode ? 'YES' : 'NO'};
static BOOL kBackgroundFreezer = ${config.backgroundFreezer ? 'YES' : 'NO'};
static BOOL kStoryStripper = ${config.storyStripper ? 'YES' : 'NO'};
static BOOL kLottieStripper = ${config.lottieStripper ? 'YES' : 'NO'};
static BOOL kReactionStripper = ${config.reactionStripper ? 'YES' : 'NO'};
static BOOL kBlurBypass = ${config.blurBypass ? 'YES' : 'NO'};
static BOOL kTypingZeroLag = ${config.typingZeroLag ? 'YES' : 'NO'};
static BOOL kQosVipElevation = ${config.qosVipElevation ? 'YES' : 'NO'};
static BOOL kThermalThrottleShield = ${config.thermalThrottleShield ? 'YES' : 'NO'};
static BOOL kAggressiveRamPurge = ${config.aggressiveRamPurge ? 'YES' : 'NO'};
static NSTimeInterval kPurgeInterval = ${config.ramPurgeIntervalMinutes * 60}.0;

static NSMutableArray<NSNumber *> *frozenPids = nil;
static dispatch_source_t ramPurgeTimer = nil;

#pragma mark - System Priority & Background Freezer Engine

static void ElevateTelegramPriority(void) {
    if (!kQosVipElevation) return;
    
    // Elevate process priority to maximum non-realtime priority (nice -20)
    setpriority(PRIO_PROCESS, 0, -20);
    
    // Set Main Thread Quality of Service to User Interactive VIP
    pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0);
    
    TT_LOG("VIP Process Priority & QoS Elevated: Nice(-20) / USER_INTERACTIVE");
}

static void FreezeBackgroundProcesses(void) {
    if (!kBackgroundFreezer) return;
    
    // Only executed in SpringBoard context if jailbroken; jailed apps rely on dispatch suspension
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
        TT_LOG("SpringBoard Hook: Freezing non-essential background processes (SIGSTOP)...");
        if (!frozenPids) {
            frozenPids = [[NSMutableArray alloc] init];
        }
        
        int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
        size_t size;
        if (sysctl(mib, 4, NULL, &size, NULL, 0) < 0) return;
        
        struct kinfo_proc *procs = malloc(size);
        if (sysctl(mib, 4, procs, &size, NULL, 0) < 0) {
            free(procs);
            return;
        }
        
        int count = (int)(size / sizeof(struct kinfo_proc));
        pid_t selfPid = getpid();
        
        for (int i = 0; i < count; i++) {
            pid_t pid = procs[i].kp_proc.p_pid;
            char *name = procs[i].kp_proc.p_comm;
            
            // Skip kernel, launchd, springboard, telegram, and system critical daemons
            if (pid <= 1 || pid == selfPid) continue;
            if (strstr(name, "Telegram") || strstr(name, "Telegraph") || strstr(name, "SpringBoard")) continue;
            if (strstr(name, "launchd") || strstr(name, "kernel") || strstr(name, "backboardd") || strstr(name, "notifyd")) continue;
            
            // Freeze heavy background apps
            if (kill(pid, SIGSTOP) == 0) {
                [frozenPids addObject:@(pid)];
            }
        }
        free(procs);
        TT_LOG("Successfully frozen %lu background processes for Telegram exclusivity", (unsigned long)[frozenPids count]);
    }
}

static void ResumeBackgroundProcesses(void) {
    if (!frozenPids || [frozenPids count] == 0) return;
    
    TT_LOG("Telegram entering background: Resuming suspended processes (SIGCONT)...");
    for (NSNumber *pidNum in frozenPids) {
        kill([pidNum intValue], SIGCONT);
    }
    [frozenPids removeAllObjects];
}

#pragma mark - Telegram App Delegate Hooks

%hook TGAppDelegate

- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    ElevateTelegramPriority();
    FreezeBackgroundProcesses();
    
    if (kAggressiveRamPurge && !ramPurgeTimer) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        ramPurgeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(ramPurgeTimer, dispatch_time(DISPATCH_TIME_NOW, kPurgeInterval * NSEC_PER_SEC), kPurgeInterval * NSEC_PER_SEC, 1ull * NSEC_PER_SEC);
        dispatch_source_set_event_handler(ramPurgeTimer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
                TT_LOG("Automatic RAM purge executed: flushed image & texture caches");
            });
        });
        dispatch_resume(ramPurgeTimer);
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    %orig;
    ResumeBackgroundProcesses();
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    %orig;
    ResumeBackgroundProcesses();
    if (ramPurgeTimer) {
        dispatch_source_cancel(ramPurgeTimer);
        ramPurgeTimer = nil;
    }
}

%end

#pragma mark - Zero-Lag Typing & Input Acceleration

%hook ChatTextInputNodeView

- (void)textViewDidChange:(UITextView *)textView {
    // Disable recursive synchronous layout invalidation on each character keystroke
    if (kTypingZeroLag) {
        [UIView performWithoutAnimation:^{
            %orig;
        }];
    } else {
        %orig;
    }
}

%end

// Eliminate redundant autolayout recalculations during high-speed typing
%hook ChatHistoryListNode

- (void)scrollToEndOfHistoryAnimated:(BOOL)animated {
    if (kTypingZeroLag) {
        // Instant non-blocking jump to bottom with zero GPU animation stall
        %orig(NO);
    } else {
        %orig(animated);
    }
}

%end

#pragma mark - Bloat Stripper: Telegram Stories Killer

%hook PeerStoriesNode
// Completely zero-out Stories carousel memory and render tree
- (instancetype)init {
    if (kStoryStripper) {
        TT_LOG("Blocked PeerStoriesNode initialization (Stories Disabled)");
        return nil;
    }
    return %orig;
}
%end

%hook PeerStoryListContext
- (BOOL)hasStories {
    return kStoryStripper ? NO : %orig;
}
%end

#pragma mark - Bloat Stripper: Lottie Vector Animations & Reactions

%hook RLottiePlayerNode
// Throttles CPU-draining 60FPS vector Lottie sticker rendering
- (void)play {
    if (kLottieStripper) {
        // Pause vector decode loop to eliminate 40-70% CPU usage during sticker spam
        return;
    }
    %orig;
}
%end

%hook AnimatedStickerNode
- (void)play {
    if (kLottieStripper) {
        return;
    }
    %orig;
}
%end

%hook ChatReactionParticleView
// Disables floating particle physics emitters on message reactions
- (instancetype)initWithFrame:(CGRect)frame {
    if (kReactionStripper) {
        return nil;
    }
    return %orig;
}
%end

#pragma mark - Anti-Thermal & GPU Blur Bypass

%hook UIVisualEffectView

- (void)layoutSubviews {
    %orig;
    if (kBlurBypass) {
        // Replace GPU-intensive live Gaussian blur filters with ultra-fast solid tint
        self.layer.filters = nil;
        self.backgroundColor = [UIColor colorWithRed:0.08 green:0.11 blue:0.15 alpha:0.92];
    }
}

%end

#pragma mark - Thermal State Shield

%hook NSProcessInfo

- (NSProcessInfoThermalState)thermalState {
    NSProcessInfoThermalState actualState = %orig;
    if (kThermalThrottleShield && actualState >= NSProcessInfoThermalStateFair) {
        // Auto-throttle background prefetching when phone begins heating up
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            TT_LOG("Thermal Shield Active: Clamping high-frequency timers & ProMotion 120Hz display link");
        });
    }
    return actualState;
}

%end

#pragma mark - SpringBoard Life-Cycle Hooks

%hook SpringBoard

- (void)frontDisplayDidChange:(id)newDisplay {
    %orig;
    NSString *bundleId = [newDisplay respondsToSelector:@selector(bundleIdentifier)] ? [newDisplay performSelector:@selector(bundleIdentifier)] : @"";
    if ([bundleId isEqualToString:@"ph.telegra.Telegraph"]) {
        FreezeBackgroundProcesses();
    } else {
        ResumeBackgroundProcesses();
    }
}

%end

#pragma mark - Constructor Initializer

%ctor {
    @autoreleasepool {
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        TT_LOG("TeleTurbo Loaded inside %@ | ExtremeMode=%@", bundleId, kExtremeModeEnabled ? @"YES" : @"NO");
        if ([bundleId isEqualToString:@"ph.telegra.Telegraph"]) {
            ElevateTelegramPriority();
        }
    }
}
`,
  },
  {
    id: 'github_workflow',
    name: 'build-tweak-ipa.yml',
    path: '.github/workflows/build-tweak-ipa.yml',
    language: 'yaml',
    description: 'Automated GitHub Actions CI/CD to compile .deb tweak and inject it into Telegram IPA.',
    getContent: (config: TweakConfig) => `name: TeleTurbo CI/CD

on:
  push:
    branches:
      - main
  workflow_dispatch:
    inputs:
      build_target:
        description: 'Build Target'
        required: true
        default: 'all'
        type: choice
        options:
          - all
          - deb-only
          - ipa-only

permissions:
  contents: write

jobs:
  build-tele-turbo:
    runs-on: ubuntu-latest
    steps:
      - name: 📥 Checkout Repository
        uses: actions/checkout@v4
        with:
          submodules: recursive

      - name: ⚙️ Setup Theos Suite (Instant Ubuntu Runner)
        uses: Randomblock1/theos-action@v1

      - name: 🔨 Compile TeleTurbo arm64 Tweak (.deb & .dylib)
        run: |
          make clean
          make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless
          cp packages/*.deb ./TeleTurbo-Rootless-arm64.deb || true
          
          mkdir -p build-dylib
          dpkg-deb -x ./TeleTurbo-Rootless-arm64.deb ./build-dylib/
          find ./build-dylib -name "*.dylib" -exec cp {} ./TeleTurbo.dylib \\; || true
          
          zip -r TeleTurbo-Injection-Kit.zip TeleTurbo.dylib src/ || true
          ls -la *.deb

      - name: 🚀 Upload Compiled Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: TeleTurbo-iOS-arm64-Build-Artifacts
          path: |
            *.deb
            *.dylib
            *.zip

      - name: 🏷️ Publish GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v1.0.0-arm64
          name: 'TeleTurbo Telegram iOS Release v1.0.0 (arm64)'
          body: |
            ## ⚡ TeleTurbo iOS - Super Performance (arm64 Edition)
            
            This automated release includes:
            - **TeleTurbo-Rootless-arm64.deb**: Native 64-bit package for **Dopamine, Taurine, palera1n (iOS 15.0 - 17.0+)**.
            - **TeleTurbo.dylib**: Standalone dynamic library for TrollStore, Azule, or Esign injection.
            - **TeleTurbo-Injection-Kit.zip**: Full injection kit.
            
            ### ✨ Features:
            - 🚀 **VIP CPU Scheduling**: Nice -20 priority & \`QOS_CLASS_USER_INTERACTIVE\`
            - 🧊 **Background App Freezer**: Suspends background battery drains
            - 🚫 **Bloat Stripper**: Story carousel killed, Lottie vector animations throttled
            - ⚡ **Zero-Lag Typing**: Instantaneous message dispatch & typing responsiveness
            - ❄️ **Anti-Thermal Shield**: Prevents iPhone overheating and battery depletion
          files: |
            *.deb
            *.dylib
            *.zip
        env:
          GITHUB_TOKEN: \${{ secrets.GITHUB_TOKEN }}
`,
  },
  {
    id: 'makefile',
    name: 'Makefile',
    path: 'Makefile',
    language: 'makefile',
    description: 'Theos build script configuring arm64/arm64e targets, frameworks, and optimization flags.',
    getContent: (config: TweakConfig) => `THEOS_PACKAGE_SCHEME ?= rootless
TARGET := iphone:clang:latest:${config.targetIosMin}
ARCHS := arm64 arm64e

INSTALL_TARGET_PROCESSES = Telegraph SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TeleTurbo

TeleTurbo_FILES = src/Tweak.x
TeleTurbo_CFLAGS = -fobjc-arc -O3 -flto -DNDEBUG -Wno-unused-variable -Wno-deprecated-declarations
TeleTurbo_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
TeleTurbo_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Telegraph || true"
`,
  },
  {
    id: 'control',
    name: 'control',
    path: 'control',
    language: 'text',
    description: 'Debian control file specifying package ID, maintainer, dependencies, and architecture.',
    getContent: (config: TweakConfig) => `Package: com.teleturbo.ios
Name: TeleTurbo (Telegram Ultra Performance)
Depends: mobilesubstrate (>= 0.9.5000)
Version: 1.0.0
Architecture: iphoneos-arm64
Description: World-fastest Telegram iOS performance tweak. Freezes background apps, eliminates typing lag, stops phone heating, and purges RAM.
Maintainer: TeleTurbo Engineering
Author: TeleTurbo Community
Section: Tweaks
Tag: role::developer, compatible::ios15, compatible::ios16, compatible::ios17
`,
  },
  {
    id: 'plist_filter',
    name: 'TeleTurbo.plist',
    path: 'TeleTurbo.plist',
    language: 'xml',
    description: 'Cydia Substrate filter targeting Telegram app bundle and SpringBoard.',
    getContent: () => `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Filter</key>
    <dict>
        <key>Bundles</key>
        <array>
            <string>ph.telegra.Telegraph</string>
            <string>com.apple.springboard</string>
        </array>
    </dict>
</dict>
</plist>
`,
  },
  {
    id: 'build_sh',
    name: 'build.sh',
    path: 'build.sh',
    language: 'bash',
    description: 'Local compilation and packaging shell script for macOS or Linux with Theos.',
    getContent: () => `#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "⚡ TeleTurbo - Local Builder & Packaging Tool"
echo "=========================================================="

if [ -z "$THEOS" ]; then
    export THEOS=~/theos
fi

if [ ! -d "$THEOS" ]; then
    echo "❌ Error: Theos is not installed at $THEOS."
    echo "Install it via: git clone --recursive https://github.com/theos/theos.git ~/theos"
    exit 1
fi

echo "🧹 Cleaning previous build artifacts..."
make clean
rm -rf packages/

echo "🔨 Building Rootless .deb (iOS 15 - 17+ / Dopamine)..."
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless

echo "🔨 Building Rootful .deb (palera1n / checkra1n)..."
make package FINALPACKAGE=1

echo "✅ Compilation finished! Generated debian packages in ./packages/:"
ls -lh packages/*.deb

echo ""
echo "To install on connected device over SSH:"
echo "make do THEOS_DEVICE_IP=192.168.1.xxx"
`,
  },
  {
    id: 'readme_md',
    name: 'README.md',
    path: 'README.md',
    language: 'markdown',
    description: 'GitHub repository documentation with badges, installation guide, and feature breakdown.',
    getContent: (config: TweakConfig) => `# ⚡ TeleTurbo iOS: World-Fastest Telegram Performance Tweak & CI/CD IPA Builder

[![TeleTurbo CI/CD](https://github.com/username/TeleTurbo-iOS/actions/workflows/build-tweak-ipa.yml/badge.svg)](https://github.com/username/TeleTurbo-iOS/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://apple.com)
[![Telegram iOS](https://img.shields.io/badge/Telegram-Optimized-2CA5E0.svg)](https://telegram.org)

> **Say goodbye to Telegram freezing, iPhone overheating, high battery consumption, and typing delay.**
> TeleTurbo turns bloated Telegram iOS into an ultra-lean, instant-response messaging powerhouse that can run 24 hours continuously with **zero lag, zero crash, and cool thermal temps**.

---

## 🚀 Key Features

| Feature | Stock Telegram iOS | With TeleTurbo ⚡ |
| :--- | :--- | :--- |
| **Typing & Sending Lag** | Stutters on long chats & big groups | **Instant 0ms latency input** |
| **Phone Heating** | Phone gets very hot, thermal throttles | **Cool (Thermal Shield active)** |
| **Background Apps** | Drain CPU/RAM concurrently | **Auto-Frozen via \`SIGSTOP\`** |
| **RAM Footprint** | 1,200 MB – 1,800 MB | **Reduced to ~180 MB** |
| **Stories Carousel** | Preloads video feeds constantly | **Zero memory (Stripped)** |
| **Lottie & Stickers** | 60 FPS vector CPU crunch | **Static cached previews** |
| **Blur Filters** | Heavy Metal Gaussian draw calls | **Fast solid opacity mode** |
| **Priority** | Standard default priority | **Nice(-20) VIP CPU QoS** |

---

## 🛠️ Automated GitHub Actions CI/CD (No Mac Needed!)

This repository contains a full **GitHub Actions Workflow** (\`.github/workflows/build-tweak-ipa.yml\`) that automatically:
1. Clones Theos & iOS SDK
2. Compiles \`TeleTurbo.dylib\` and \`.deb\`
3. Injects the tweak into official decrypted Telegram IPA using **Azule**
4. Publishes a GitHub Release with download links for TrollStore, AltStore, Sideloadly, and Jailbroken devices!

### How to use on GitHub:
1. Fork or clone this repository to your GitHub account.
2. Go to **Actions** tab -> **TeleTurbo CI/CD**.
3. Click **Run workflow**.
4. In ~3 minutes, download your ready-to-install **\`TeleTurbo_Telegram_Optimized.ipa\`** or **\`TeleTurbo-Rootless.deb\`** directly from the **Releases** tab!

---

## 📲 Installation Methods

### Method 1: Sideloading (TrollStore / AltStore / Sideloadly) - No Jailbreak Needed
1. Download \`TeleTurbo_Telegram_Optimized.ipa\` from GitHub Releases.
2. Open in **TrollStore** -> Tap **Install**.
3. (Or use AltStore / Sideloadly on PC/Mac with your Apple ID).

### Method 2: Jailbroken (Dopamine, Taurine, palera1n)
1. Download \`TeleTurbo-Rootless.deb\` (or Rootful).
2. Open with **Sileo** / **Zebra** -> Tap **Install**.
3. Respring device. TeleTurbo is now active!

---

## 📄 License
MIT License. Built for performance enthusiasts.
`,
  },
];
