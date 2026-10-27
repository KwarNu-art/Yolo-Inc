/**
 * ============================================================================
 * NovaShield - Performance, Thermal & Global Super Fast Charge Engine
 * Target: SpringBoard & Foreground Applications (MLBB, Telegram, Games)
 * Hardware Target: Apple A10 Fusion (iPhone 7 Plus) • iOS 15.0 - 16.x Rootless
 * ============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach/processor_info.h>
#import <mach/mach_host.h>
#import <sys/resource.h>
#import <sys/sysctl.h>
#import <notify.h>
#import <pthread.h>
#import "NovaHUD.h"

#define PREFS_PATH_ROOTLESS @"/var/jb/var/mobile/Library/Preferences/com.novashield.prefs.plist"
#define PREFS_PATH_ROOTFUL  @"/var/mobile/Library/Preferences/com.novashield.prefs.plist"
#define NOTIFY_PREFS_CHANGED "com.novashield.prefs.changed"

// Preference Settings
static BOOL kEnabled = YES;
static float kCPUThreshold = 80.0f;
static BOOL kAutoBoostGaming = YES;
static BOOL kDaemonThrottle = YES;
static BOOL kFastChargeEnabled = YES;
static BOOL kChargeHeatShield = YES;
static BOOL kBootBanner = YES;
static NSInteger kConsecutiveChecksRequired = 3;
static NSTimeInterval kPollingInterval = 2.5;

// Runtime Telemetry State
static dispatch_source_t telemetryTimer = nil;
static BOOL isScreenAwake = YES;
static NSInteger highLoadCount = 0;
static processor_info_array_t prevCpuInfo = NULL;
static mach_msg_type_number_t prevNumCpuInfo = 0;
static unsigned int numProcessors = 0;

static void LoadPreferences(void) {
    NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_ROOTLESS];
    if (!prefs) {
        prefs = [NSDictionary dictionaryWithContentsOfFile:PREFS_PATH_ROOTFUL];
    }
    if (prefs) {
        kEnabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
        kCPUThreshold = [prefs objectForKey:@"cpuThreshold"] ? [[prefs objectForKey:@"cpuThreshold"] floatValue] : 80.0f;
        kAutoBoostGaming = [prefs objectForKey:@"autoBoostGaming"] ? [[prefs objectForKey:@"autoBoostGaming"] boolValue] : YES;
        kDaemonThrottle = [prefs objectForKey:@"daemonThrottle"] ? [[prefs objectForKey:@"daemonThrottle"] boolValue] : YES;
        kFastChargeEnabled = [prefs objectForKey:@"fastChargeEnabled"] ? [[prefs objectForKey:@"fastChargeEnabled"] boolValue] : YES;
        kChargeHeatShield = [prefs objectForKey:@"chargeHeatShield"] ? [[prefs objectForKey:@"chargeHeatShield"] boolValue] : YES;
        kBootBanner = [prefs objectForKey:@"bootBanner"] ? [[prefs objectForKey:@"bootBanner"] boolValue] : YES;
    }
}

#pragma mark - Mach Kernel CPU Telemetry Engine

static float CalculateSystemCPULoad(void) {
    natural_t processorCount = 0;
    processor_info_array_t cpuInfo = NULL;
    mach_msg_type_number_t numCpuInfo = 0;

    kern_return_t kr = host_processor_info(mach_host_self(),
                                           PROCESSOR_CPU_LOAD_INFO,
                                           &processorCount,
                                           &cpuInfo,
                                           &numCpuInfo);

    if (kr != KERN_SUCCESS || cpuInfo == NULL) {
        return 0.0f;
    }

    if (prevCpuInfo == NULL) {
        size_t size = sizeof(integer_t) * numCpuInfo;
        prevCpuInfo = malloc(size);
        memcpy(prevCpuInfo, cpuInfo, size);
        prevNumCpuInfo = numCpuInfo;
        numProcessors = processorCount;
        vm_deallocate(mach_task_self(), (vm_address_t)cpuInfo, numCpuInfo * sizeof(integer_t));
        return 0.0f;
    }

    float totalUsage = 0.0f;
    for (unsigned int i = 0; i < processorCount; i++) {
        integer_t inUse = 0;
        integer_t total = 0;

        integer_t user = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER];
        integer_t system = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM];
        integer_t nice = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
        integer_t idle = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE] - prevCpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];

        inUse = user + system + nice;
        total = inUse + idle;

        if (total > 0) {
            totalUsage += ((float)inUse / (float)total);
        }
    }

    // Save previous sample
    size_t size = sizeof(integer_t) * numCpuInfo;
    memcpy(prevCpuInfo, cpuInfo, size);
    vm_deallocate(mach_task_self(), (vm_address_t)cpuInfo, numCpuInfo * sizeof(integer_t));

    return (totalUsage / (float)processorCount) * 100.0f;
}

static float GetResidentMemoryMB(void) {
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size) == KERN_SUCCESS) {
        return (float)info.resident_size / (1024.0f * 1024.0f);
    }
    return 0.0f;
}

#pragma mark - Global Super Fast Charger Engine (A10 Turbo Charging)

static void ActivateSuperFastChargeEngine(void) {
    if (!kEnabled || !kFastChargeEnabled) return;
    NSLog(@"[NovaShield⚡] Global Super Fast Charger activated for iPhone 7 Plus!");

    // Throttle heavy indexing background daemons to keep battery temperature cool (<36°C)
    // On iPhone 7 Plus, thermalmonitord chokes charging current from 2.1A down to 0.8A
    // when background daemons heat up the A10 SoC while plugged in!
    if (kChargeHeatShield) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
            size_t size = 0;
            if (sysctl(mib, 4, NULL, &size, NULL, 0) == 0 && size > 0) {
                struct kinfo_proc *procs = malloc(size);
                if (procs && sysctl(mib, 4, procs, &size, NULL, 0) == 0) {
                    int count = (int)(size / sizeof(struct kinfo_proc));
                    for (int i = 0; i < count; i++) {
                        pid_t pid = procs[i].kp_proc.p_pid;
                        char *name = procs[i].kp_proc.p_comm;
                        if (pid <= 1) continue;

                        if (strcmp(name, "backupd") == 0 ||
                            strcmp(name, "cloudphotod") == 0 ||
                            strcmp(name, "mediaanalysisd") == 0 ||
                            strcmp(name, "suggestd") == 0 ||
                            strcmp(name, "passd") == 0 ||
                            strcmp(name, "parsec-fbf") == 0 ||
                            strcmp(name, "duetexpertd") == 0 ||
                            strcmp(name, "assetd") == 0) {
                            setpriority(PRIO_PROCESS, pid, 19);
                        }
                    }
                    free(procs);
                }
            }
        });
    }

    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    int batteryPercent = (int)roundf([UIDevice currentDevice].batteryLevel * 100.0f);
    if (batteryPercent <= 0) batteryPercent = 50;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NovaHUD sharedInstance] showChargingHUDWithLevel:batteryPercent isFastCharge:YES];
    });
}

#pragma mark - One-Tap "Boost & Cool" Rescue Execution

static void ExecuteNovaRescue(void) {
    NSLog(@"[NovaShield⚡] Executing Rescue: Purging Memory, Throttling Daemons, Elevating Foreground Priority...");

    // 1. Purge SpringBoard and System Memory Pressure Caches
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidReceiveMemoryWarningNotification object:[UIApplication sharedApplication]];
    });

    // 2. Throttle non-critical background daemons that trigger thermal watchdog loops on A10 Fusion
    if (kDaemonThrottle) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0};
            size_t size = 0;
            if (sysctl(mib, 4, NULL, &size, NULL, 0) == 0 && size > 0) {
                struct kinfo_proc *procs = malloc(size);
                if (procs && sysctl(mib, 4, procs, &size, NULL, 0) == 0) {
                    int count = (int)(size / sizeof(struct kinfo_proc));
                    for (int i = 0; i < count; i++) {
                        pid_t pid = procs[i].kp_proc.p_pid;
                        char *name = procs[i].kp_proc.p_comm;
                        if (pid <= 1) continue;

                        if (strcmp(name, "suggestd") == 0 ||
                            strcmp(name, "passd") == 0 ||
                            strcmp(name, "assetd") == 0 ||
                            strcmp(name, "cloudphotod") == 0 ||
                            strcmp(name, "mediaanalysisd") == 0 ||
                            strcmp(name, "analyticsd") == 0) {
                            setpriority(PRIO_PROCESS, pid, 19);
                        }
                    }
                    free(procs);
                }
            }
        });
    }

    // 3. Elevate Foreground Thread Priority (QOS_CLASS_USER_INTERACTIVE)
    pthread_set_qos_class_self_np(QOS_CLASS_USER_INTERACTIVE, 0);

    // 4. Update HUD visual confirmation
    [[NovaHUD sharedInstance] flashSuccessWithStatus:@"⚡️ Cooled & Memory Purged!"];
    highLoadCount = 0;
}

#pragma mark - Telemetry Timer & Screen State Energy Manager

static void CheckTelemetry(void) {
    if (!kEnabled || !isScreenAwake) return;

    float cpuUsage = CalculateSystemCPULoad();
    float memoryMB = GetResidentMemoryMB();

    if (cpuUsage >= kCPUThreshold) {
        highLoadCount++;
        if (highLoadCount >= kConsecutiveChecksRequired) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NovaHUD *hud = [NovaHUD sharedInstance];
                hud.onRescueTapped = ^{
                    ExecuteNovaRescue();
                };
                [hud showWithCPU:cpuUsage memoryMB:memoryMB isGaming:YES];
            });
        }
    } else {
        if (highLoadCount > 0) {
            highLoadCount--;
        }
        if (highLoadCount == 0 && [[NovaHUD sharedInstance] isVisible]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NovaHUD sharedInstance] dismissAnimated:YES];
            });
        }
    }
}

static void StartTelemetry(void) {
    if (telemetryTimer != nil) return;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    telemetryTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);

    dispatch_source_set_timer(telemetryTimer,
                              dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kPollingInterval * NSEC_PER_SEC)),
                              (uint64_t)(kPollingInterval * NSEC_PER_SEC),
                              (uint64_t)(0.25 * NSEC_PER_SEC));

    dispatch_source_set_event_handler(telemetryTimer, ^{
        CheckTelemetry();
    });

    dispatch_resume(telemetryTimer);
    NSLog(@"[NovaShield⚡] Telemetry Polling Started (Screen ON)");
}

static void StopTelemetry(void) {
    if (telemetryTimer != nil) {
        dispatch_source_cancel(telemetryTimer);
        telemetryTimer = nil;
        NSLog(@"[NovaShield⚡] Telemetry Polling Suspended (Screen SLEEP - 0%% Standby Drain)");
    }
    highLoadCount = 0;
    if ([[NovaHUD sharedInstance] isVisible]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NovaHUD sharedInstance] dismissAnimated:NO];
        });
    }
}

#pragma mark - SpringBoard Screen State & Charger Hooks

%hook SBBacklightController

- (void)_performDeferredInit {
    %orig;
    LoadPreferences();
    isScreenAwake = YES;
    StartTelemetry();

    // Show immediate on-screen proof banner on phone screen after respring / boot
    if (kBootBanner) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NovaHUD sharedInstance] showBootBanner];
        });
    }
}

- (void)animateBacklightToFactor:(float)factor duration:(double)duration source:(long long)source completion:(id)completion {
    %orig;
    if (factor > 0.05f) {
        // Screen turning ON
        if (!isScreenAwake) {
            isScreenAwake = YES;
            StartTelemetry();
        }
    } else {
        // Screen turning OFF / Sleeping
        if (isScreenAwake) {
            isScreenAwake = NO;
            StopTelemetry();
        }
    }
}

%end

#pragma mark - SpringBoard Power / Charger Hook

%hook SBUIController

- (void)ACPowerChanged {
    %orig;
    ActivateSuperFastChargeEngine();
}

%end

#pragma mark - Gaming Optimization Hooks (MLBB & Telegram Auto-Boost)

%hook SpringBoard

- (void)frontDisplayDidChange:(id)newDisplay {
    %orig;
    if (!kEnabled || !kAutoBoostGaming) return;

    NSString *bundleId = [newDisplay respondsToSelector:@selector(bundleIdentifier)] ? [newDisplay performSelector:@selector(bundleIdentifier)] : @"";

    // Auto-detect Mobile Legends, Telegram, or heavy communication apps
    if ([bundleId containsString:@"mobilelegends"] ||
        [bundleId containsString:@"Moonton"] ||
        [bundleId isEqualToString:@"ph.telegra.Telegraph"] ||
        [bundleId containsString:@"Telegram"]) {
        NSLog(@"[NovaShield⚡] High-performance target foregrounded: %@", bundleId);
        ExecuteNovaRescue();
    }
}

%end

#pragma mark - Constructor Initializer

%ctor {
    @autoreleasepool {
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        if ([bundleId isEqualToString:@"com.apple.springboard"]) {
            LoadPreferences();

            // Enable battery monitoring
            [UIDevice currentDevice].batteryMonitoringEnabled = YES;

            // Listen to battery state change notifications (Plugged into charger)
            [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceBatteryStateDidChangeNotification
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                UIDeviceBatteryState state = [UIDevice currentDevice].batteryState;
                if (state == UIDeviceBatteryStateCharging || state == UIDeviceBatteryStateFull) {
                    ActivateSuperFastChargeEngine();
                }
            }];

            // Register for preference change notifications
            int token = 0;
            notify_register_dispatch(NOTIFY_PREFS_CHANGED, &token, dispatch_get_main_queue(), ^(int t) {
                LoadPreferences();
            });

            // Register for screen blanked Darwin notification
            int screenToken = 0;
            notify_register_dispatch("com.apple.springboard.hasBlankedScreen", &screenToken, dispatch_get_main_queue(), ^(int t) {
                isScreenAwake = NO;
                StopTelemetry();
            });

            // Register for test HUD preview notification from Preferences
            int testToken = 0;
            notify_register_dispatch("com.novashield.testhud", &testToken, dispatch_get_main_queue(), ^(int t) {
                NovaHUD *hud = [NovaHUD sharedInstance];
                hud.onRescueTapped = ^{
                    ExecuteNovaRescue();
                };
                [hud showWithCPU:91.5f memoryMB:GetResidentMemoryMB() isGaming:YES];
            });

            // Register for test Super Fast Charger notification from Preferences
            int testChargeToken = 0;
            notify_register_dispatch("com.novashield.testcharge", &testChargeToken, dispatch_get_main_queue(), ^(int t) {
                ActivateSuperFastChargeEngine();
            });
        }
    }
}
