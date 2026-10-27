/**
 * ============================================================================
 * Gesture-X: iPhone X Style Fluid Gestures Engine for iPhone 7 Plus (A10)
 * Target: SpringBoard & iOS 15.0 - 15.8.x Rootless (Dopamine / Palera1n)
 * Architecture: arm64
 * ============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <notify.h>
#import "GXHUD.h"

#define PREFS_PATH_ROOTLESS @"/var/jb/var/mobile/Library/Preferences/com.gesturex.prefs.plist"
#define PREFS_PATH_ROOTFUL  @"/var/mobile/Library/Preferences/com.gesturex.prefs.plist"
#define NOTIFY_PREFS_CHANGED "com.gesturex.prefs.changed"

// Preferences
static BOOL kEnabled = YES;
static BOOL kHideHomeBar = NO;
static BOOL kModernKeyboard = YES;
static BOOL kLockscreenButtons = YES;
static BOOL kHapticFeedback = YES;
static BOOL kBootBanner = YES;
static NSInteger kStatusBarStyle = 0; // 0 = Modern iPhone X, 1 = Classic iPhone 7, 2 = iPad

static void LoadPreferences(void) {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_ROOTLESS];
    if (!prefs) {
        prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_ROOTFUL];
    }
    if (prefs) {
        kEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        kHideHomeBar = [prefs objectForKey:@"hideHomeBar"] ? [[prefs objectForKey:@"hideHomeBar"] boolValue] : NO;
        kModernKeyboard = [prefs objectForKey:@"modernKeyboard"] ? [[prefs objectForKey:@"modernKeyboard"] boolValue] : YES;
        kLockscreenButtons = [prefs objectForKey:@"lockscreenButtons"] ? [[prefs objectForKey:@"lockscreenButtons"] boolValue] : YES;
        kHapticFeedback = [prefs objectForKey:@"hapticFeedback"] ? [[prefs objectForKey:@"hapticFeedback"] boolValue] : YES;
        kBootBanner = [prefs objectForKey:@"bootBanner"] ? [[prefs objectForKey:@"bootBanner"] boolValue] : YES;
        kStatusBarStyle = [prefs objectForKey:@"statusBarStyle"] ? [[prefs objectForKey:@"statusBarStyle"] integerValue] : 0;
    }
}

#pragma mark - Core iPhone X Fluid Gestures Engine (BSPlatform)

%hook BSPlatform

- (NSInteger)homeButtonType {
    if (kEnabled) {
        // Return 2 (No Home Button / Fluid Gesture iPhone X device type)
        // This natively unlocks:
        // 1. Swipe up to go Home from any app
        // 2. Swipe up and hold for App Switcher
        // 3. Horizontal flick across bottom edge for fast app switching
        // 4. Control Center swipe-down from top-right corner
        // 5. CoverSheet / Notification swipe-down from top-left corner
        return 2;
    }
    return %orig;
}

%end

#pragma mark - Bottom Home Grabber Bar Visibility

%hook SBHomeGrabberView

- (BOOL)isHidden {
    if (kEnabled && kHideHomeBar) {
        return YES;
    }
    return %orig;
}

- (void)setHidden:(BOOL)hidden {
    if (kEnabled && kHideHomeBar) {
        %orig(YES);
    } else {
        %orig(hidden);
    }
}

%end

%hook MTLSHomeAffordanceView

- (BOOL)isHidden {
    if (kEnabled && kHideHomeBar) {
        return YES;
    }
    return %orig;
}

- (void)setHidden:(BOOL)hidden {
    if (kEnabled && kHideHomeBar) {
        %orig(YES);
    } else {
        %orig(hidden);
    }
}

%end

#pragma mark - Keyboard Modern Bottom Inset & Globe Key

%hook UIKeyboardImpl

- (UIEdgeInsets)_extraInsetsForDeviceType {
    if (kEnabled && kModernKeyboard) {
        // iPhone X keyboard spacing beneath the spacebar
        return UIEdgeInsetsMake(0, 0, 36.0, 0);
    }
    return %orig;
}

%end

#pragma mark - Lock Screen Quick Action Buttons (Flashlight & Camera)

%hook CSCoverSheetViewController

- (BOOL)hasCustomCoverSheet {
    if (kEnabled && kLockscreenButtons) {
        return YES;
    }
    return %orig;
}

%end

#pragma mark - Fluid Switcher Haptic Feedback

%hook SBFluidSwitcherGestureManager

- (void)fluidSwitcherGestureTransaction:(id)arg1 didBeginGesture:(id)arg2 {
    %orig;
    if (kEnabled && kHapticFeedback) {
        AudioServicesPlaySystemSound(1519); // Subtle peek haptic on swipe-up
    }
}

%end

#pragma mark - SpringBoard Initialization & Proof Banner

%hook SBBacklightController

- (void)_performDeferredInit {
    %orig;
    LoadPreferences();

    // Display on-screen proof banner upon boot/respring confirming Gesture-X is active
    if (kEnabled && kBootBanner) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[GXHUD sharedInstance] showBootBanner];
        });
    }
}

%end

#pragma mark - Constructor Initializer

%ctor {
    @autoreleasepool {
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        if ([bundleId isEqualToString:@"com.apple.springboard"]) {
            LoadPreferences();

            // Register preference change notification
            int token = 0;
            notify_register_dispatch(NOTIFY_PREFS_CHANGED, &token, dispatch_get_main_queue(), ^(int t) {
                LoadPreferences();
            });

            // Register Darwin notification for test HUD preview from Settings
            int testToken = 0;
            notify_register_dispatch("com.gesturex.testhud", &testToken, dispatch_get_main_queue(), ^(int t) {
                [[GXHUD sharedInstance] showGestureTriggeredHUD:@"Swipe Up to Home"];
            });
        }
    }
}
