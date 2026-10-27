#import "NovaHUD.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface NovaHUD ()

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *statsLabel;
@property (nonatomic, strong) UIButton *boostButton;
@property (nonatomic, strong) UIView *pulseDot;
@property (nonatomic, strong) NSTimer *autoDismissTimer;

@end

@implementation NovaHUD

+ (instancetype)sharedInstance {
    static NovaHUD *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NovaHUD alloc] init];
    });
    return instance;
}

- (instancetype)init {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat hudWidth = MIN(screenWidth - 32.0, 360.0);
    CGFloat hudHeight = 84.0;
    CGFloat topInset = 54.0; // Safe area below notch/status bar

    CGRect frame = CGRectMake((screenWidth - hudWidth) / 2.0, topInset, hudWidth, hudHeight);

    if ((self = [super initWithFrame:frame])) {
        self.windowLevel = UIWindowLevelAlert + 100.0;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;

        // Container view with Apple-style continuous rounded corners
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.layer.cornerRadius = 20.0;
        _containerView.layer.cornerCurve = kCACornerCurveContinuous;
        _containerView.layer.masksToBounds = NO;
        _containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        _containerView.layer.shadowOffset = CGSizeMake(0, 10);
        _containerView.layer.shadowRadius = 24.0;
        _containerView.layer.shadowOpacity = 0.45;
        [self addSubview:_containerView];

        // Apple-style Glassmorphism blur effect
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurView.frame = _containerView.bounds;
        _blurView.layer.cornerRadius = 20.0;
        _blurView.layer.cornerCurve = kCACornerCurveContinuous;
        _blurView.layer.masksToBounds = YES;
        _blurView.layer.borderWidth = 1.0;
        _blurView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.18].CGColor;
        [_containerView addSubview:_blurView];

        // Content layout inside blur
        UIView *content = _blurView.contentView;

        // Pulsing Neon Status Dot
        _pulseDot = [[UIView alloc] initWithFrame:CGRectMake(14, 18, 9, 9)];
        _pulseDot.layer.cornerRadius = 4.5;
        _pulseDot.backgroundColor = [UIColor colorWithRed:1.0 green:0.32 blue:0.32 alpha:1.0];
        _pulseDot.layer.shadowColor = [UIColor colorWithRed:1.0 green:0.32 blue:0.32 alpha:0.9].CGColor;
        _pulseDot.layer.shadowRadius = 6.0;
        _pulseDot.layer.shadowOpacity = 1.0;
        [content addSubview:_pulseDot];

        // Title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 12, 175, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"NovaShield Alert";
        [content addSubview:_titleLabel];

        // Status text (e.g., Thermal Throttle Watchdog)
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 32, 195, 16)];
        _statusLabel.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightMedium];
        _statusLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        _statusLabel.text = @"A10 High Thermal & CPU Load";
        [content addSubview:_statusLabel];

        // Telemetry stats row
        _statsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 54, 215, 18)];
        _statsLabel.font = [UIFont monospacedDigitSystemFontOfSize:11.0 weight:UIFontWeightSemibold];
        _statsLabel.textColor = [UIColor colorWithRed:0.22 green:0.88 blue:1.0 alpha:1.0];
        _statsLabel.text = @"CPU: 88% • RAM: 1.8GB";
        [content addSubview:_statsLabel];

        // Embedded "⚡️ Boost & Cool" Direct Action Button
        _boostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnWidth = 110.0;
        CGFloat btnHeight = 44.0;
        _boostButton.frame = CGRectMake(hudWidth - btnWidth - 12.0, (hudHeight - btnHeight) / 2.0, btnWidth, btnHeight);
        _boostButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.55 blue:1.0 alpha:0.95];
        _boostButton.layer.cornerRadius = 14.0;
        _boostButton.layer.cornerCurve = kCACornerCurveContinuous;
        _boostButton.layer.masksToBounds = YES;
        _boostButton.titleLabel.font = [UIFont systemFontOfSize:12.5 weight:UIFontWeightBold];
        [_boostButton setTitle:@"⚡️ Boost & Cool" forState:UIControlStateNormal];
        [_boostButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_boostButton addTarget:self action:@selector(handleRescueTapped) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:_boostButton];

        // Swipe up gesture to dismiss
        UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeUp:)];
        swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeUp];
    }
    return self;
}

- (BOOL)isVisible {
    return !self.hidden && self.alpha > 0.01;
}

- (void)showBootBanner {
    [self.autoDismissTimer invalidate];

    self.titleLabel.text = @"⚡️ NovaShield Online";
    self.statusLabel.text = @"A10 Rescue & Super Fast Charge";
    self.statsLabel.text = @"SpringBoard Hooked • 0% Standby Drain";
    self.pulseDot.backgroundColor = [UIColor colorWithRed:0.2 green:0.95 blue:0.45 alpha:1.0];
    self.blurView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.85 blue:0.4 alpha:0.45].CGColor;
    [self.boostButton setTitle:@"✅ Active" forState:UIControlStateNormal];
    self.boostButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.7 blue:0.3 alpha:0.95];

    if (!self.isVisible) {
        self.hidden = NO;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeTranslation(0, -60.0);

        [UIView animateWithDuration:0.55
                              delay:0.0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0.4
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.alpha = 1.0;
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }

    self.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(autoDismiss) userInfo:nil repeats:NO];
}

- (void)showChargingHUDWithLevel:(int)batteryLevel isFastCharge:(BOOL)isFastCharge {
    [self.autoDismissTimer invalidate];

    self.titleLabel.text = isFastCharge ? @"⚡️ Super Fast Charger (A10)" : @"⚡️ Smart Battery Charging";
    self.statusLabel.text = isFastCharge ? @"Thermal Throttling Bypassed • 2.1A Max" : @"A10 Low-Heat Safe Charge";
    self.statsLabel.text = [NSString stringWithFormat:@"Battery: %d%% • Background Freezing Active", batteryLevel];
    self.pulseDot.backgroundColor = [UIColor colorWithRed:0.0 green:0.95 blue:1.0 alpha:1.0];
    self.blurView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.55].CGColor;
    [self.boostButton setTitle:isFastCharge ? @"⚡️ Turbo" : @"🔋 Charging" forState:UIControlStateNormal];
    self.boostButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.55 blue:0.95 alpha:0.95];

    if (!self.isVisible) {
        self.hidden = NO;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeTranslation(0, -60.0);

        [UIView animateWithDuration:0.55
                              delay:0.0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0.4
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.alpha = 1.0;
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }

    self.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:4.5 target:self selector:@selector(autoDismiss) userInfo:nil repeats:NO];
}

- (void)showWithCPU:(float)cpuPercent memoryMB:(float)memoryMB isGaming:(BOOL)isGaming {
    [self.autoDismissTimer invalidate];

    self.statsLabel.text = [NSString stringWithFormat:@"CPU: %.0f%% • RAM: %.0fMB", cpuPercent, memoryMB];

    if (isGaming) {
        self.titleLabel.text = @"NovaShield Gaming Rescue";
        self.statusLabel.text = @"MLBB/Telegram High Thermal Spike";
        self.pulseDot.backgroundColor = [UIColor colorWithRed:1.0 green:0.25 blue:0.25 alpha:1.0];
        self.blurView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.45].CGColor;
    } else {
        self.titleLabel.text = @"NovaShield Rescue Engine";
        self.statusLabel.text = @"A10 Background Runaway Throttled";
        self.pulseDot.backgroundColor = [UIColor colorWithRed:1.0 green:0.65 blue:0.0 alpha:1.0];
        self.blurView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.7 blue:1.0 alpha:0.35].CGColor;
    }

    [self.boostButton setTitle:@"⚡️ Boost & Cool" forState:UIControlStateNormal];
    self.boostButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.55 blue:1.0 alpha:0.95];

    if (!self.isVisible) {
        self.hidden = NO;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeTranslation(0, -60.0);

        [UIView animateWithDuration:0.55
                              delay:0.0
             usingSpringWithDamping:0.78
              initialSpringVelocity:0.4
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.alpha = 1.0;
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }

    // Schedule auto dismiss after 7 seconds if not manually tapped
    self.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(autoDismiss) userInfo:nil repeats:NO];
}

- (void)handleRescueTapped {
    [self.autoDismissTimer invalidate];

    // Haptic feedback
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
        [feedback prepare];
        [feedback impactOccurred];
    }

    // Button animation
    [UIView animateWithDuration:0.15 animations:^{
        self.boostButton.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.boostButton.transform = CGAffineTransformIdentity;
        }];
    }];

    if (self.onRescueTapped) {
        self.onRescueTapped();
    }
}

- (void)flashSuccessWithStatus:(NSString *)statusText {
    self.statusLabel.text = statusText;
    self.pulseDot.backgroundColor = [UIColor colorWithRed:0.2 green:0.95 blue:0.45 alpha:1.0];
    self.blurView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.95 blue:0.45 alpha:0.75].CGColor;
    [self.boostButton setTitle:@"✅ Cooled!" forState:UIControlStateNormal];
    self.boostButton.backgroundColor = [UIColor colorWithRed:0.15 green:0.75 blue:0.35 alpha:0.95];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissAnimated:YES];
        // Reset button text
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.boostButton setTitle:@"⚡️ Boost & Cool" forState:UIControlStateNormal];
            self.boostButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.55 blue:1.0 alpha:0.95];
        });
    });
}

- (void)handleSwipeUp:(UISwipeGestureRecognizer *)gesture {
    [self dismissAnimated:YES];
}

- (void)autoDismiss {
    [self dismissAnimated:YES];
}

- (void)dismissAnimated:(BOOL)animated {
    [self.autoDismissTimer invalidate];
    self.autoDismissTimer = nil;

    if (!animated) {
        self.alpha = 0.0;
        self.hidden = YES;
        return;
    }

    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeTranslation(0, -60.0);
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.transform = CGAffineTransformIdentity;
    }];
}

@end
