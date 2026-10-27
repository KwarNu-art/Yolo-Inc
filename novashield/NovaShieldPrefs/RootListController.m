#import "RootListController.h"
#import <notify.h>
#import <spawn.h>

@implementation NovaShieldRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)testChargeHUD {
    // Post Darwin notification to SpringBoard to test Super Fast Charge HUD
    notify_post("com.novashield.testcharge");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚡️ Super Fast Charger Active"
                                                                   message:@"The Super Fast Charge HUD has been displayed on screen. Thermal throttling is bypassed and heavy background daemons are throttled."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)testHUD {
    // Post Darwin notification to SpringBoard to test NovaHUD preview
    notify_post("com.novashield.testhud");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"⚡️ NovaHUD Triggered"
                                                                   message:@"The blurred glassmorphism HUD has been dispatched to SpringBoard. Swipe up on the HUD or tap 'Boost & Cool' to interact."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openGitHub {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/KwarNu-art/Microlab-2"] options:@{} completionHandler:nil];
}

- (void)respring {
    pid_t pid;
    const char *args[] = {"killall", "-9", "SpringBoard", NULL};
    posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);
}

@end
