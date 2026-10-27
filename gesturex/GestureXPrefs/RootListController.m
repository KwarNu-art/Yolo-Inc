#import "RootListController.h"
#import <notify.h>
#import <spawn.h>

@implementation GestureXRootListController

- (NSArray *)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
    }
    return _specifiers;
}

- (void)testHUD {
    // Post Darwin notification to SpringBoard to test Gesture-X preview
    notify_post("com.gesturex.testhud");

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"📲 Gesture-X HUD Dispatched"
                                                                   message:@"The modern gesture HUD has been displayed on screen. Swipe up from the bottom edge in any app to test Home navigation!"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)openGitHub {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/KwarNu-art/Gesture-X"] options:@{} completionHandler:nil];
}

- (void)respring {
    pid_t pid;
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb/usr/bin/sbreload"]) {
        const char *args[] = {"sbreload", NULL};
        posix_spawn(&pid, "/var/jb/usr/bin/sbreload", NULL, NULL, (char *const *)args, NULL);
    } else {
        const char *args[] = {"killall", "-9", "SpringBoard", NULL};
        posix_spawn(&pid, "/var/jb/usr/bin/killall", NULL, NULL, (char *const *)args, NULL);
    }
}

@end
