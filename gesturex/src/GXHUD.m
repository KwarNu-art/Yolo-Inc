#import "GXHUD.h"
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@interface GXHUD ()

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *statsLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIView *pulseDot;
@property (nonatomic, strong) NSTimer *autoDismissTimer;

@end

@implementation GXHUD

+ (instancetype)sharedInstance {
    static GXHUD *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GXHUD alloc] init];
    });
    return instance;
}

- (instancetype)init {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat hudWidth = MIN(screenWidth - 32.0, 360.0);
    CGFloat hudHeight = 84.0;
    CGFloat topInset = 54.0;

    CGRect frame = CGRectMake((screenWidth - hudWidth) / 2.0, topInset, hudWidth, hudHeight);

    if ((self = [super initWithFrame:frame])) {
        self.windowLevel = UIWindowLevelAlert + 100.0;
        self.backgroundColor = [UIColor clearColor];
        self.hidden = YES;

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

        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterialDark];
        _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _blurView.frame = _containerView.bounds;
        _blurView.layer.cornerRadius = 20.0;
        _blurView.layer.cornerCurve = kCACornerCurveContinuous;
        _blurView.layer.masksToBounds = YES;
        _blurView.layer.borderWidth = 1.0;
        _blurView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.6 blue:1.0 alpha:0.4].CGColor;
        [_containerView addSubview:_blurView];

        UIView *content = _blurView.contentView;

        // Pulsing Neon Status Dot
        _pulseDot = [[UIView alloc] initWithFrame:CGRectMake(14, 18, 9, 9)];
        _pulseDot.layer.cornerRadius = 4.5;
        _pulseDot.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0];
        _pulseDot.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.9].CGColor;
        _pulseDot.layer.shadowRadius = 6.0;
        _pulseDot.layer.shadowOpacity = 1.0;
        [content addSubview:_pulseDot];

        // Title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 12, 210, 20)];
        _titleLabel.font = [UIFont systemFontOfSize:14.0 weight:UIFontWeightBold];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"Gesture-X Online 📲";
        [content addSubview:_titleLabel];

        // Status text
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 32, 210, 16)];
        _statusLabel.font = [UIFont systemFontOfSize:11.5 weight:UIFontWeightMedium];
        _statusLabel.textColor = [UIColor colorWithWhite:0.85 alpha:1.0];
        _statusLabel.text = @"iPhone X Gestures on iPhone 7 Plus";
        [content addSubview:_statusLabel];

        // Telemetry stats row
        _statsLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 54, 230, 18)];
        _statsLabel.font = [UIFont monospacedDigitSystemFontOfSize:11.0 weight:UIFontWeightSemibold];
        _statsLabel.textColor = [UIColor colorWithRed:0.25 green:0.88 blue:1.0 alpha:1.0];
        _statsLabel.text = @"Swipe Up: Home • Corner: CC";
        [content addSubview:_statsLabel];

        // Action badge button
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnWidth = 92.0;
        CGFloat btnHeight = 44.0;
        _actionButton.frame = CGRectMake(hudWidth - btnWidth - 12.0, (hudHeight - btnHeight) / 2.0, btnWidth, btnHeight);
        _actionButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:0.95];
        _actionButton.layer.cornerRadius = 14.0;
        _actionButton.layer.cornerCurve = kCACornerCurveContinuous;
        _actionButton.layer.masksToBounds = YES;
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:12.5 weight:UIFontWeightBold];
        [_actionButton setTitle:@"Active" forState:UIControlStateNormal];
        [_actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_actionButton addTarget:self action:@selector(handleActionTapped) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:_actionButton];

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

    self.titleLabel.text = @"Gesture-X Online 📲";
    self.statusLabel.text = @"iPhone X Fluid Gestures Active";
    self.statsLabel.text = @"Swipe Up to Go Home • Corner for CC";
    self.pulseDot.backgroundColor = [UIColor colorWithRed:0.1 green:0.95 blue:0.45 alpha:1.0];
    self.blurView.layer.borderColor = [UIColor colorWithRed:0.1 green:0.85 blue:0.4 alpha:0.5].CGColor;
    [self.actionButton setTitle:@"✅ Loaded" forState:UIControlStateNormal];
    self.actionButton.backgroundColor = [UIColor colorWithRed:0.1 green:0.7 blue:0.35 alpha:0.95];

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

- (void)showGestureTriggeredHUD:(NSString *)gestureName {
    [self.autoDismissTimer invalidate];

    self.titleLabel.text = [NSString stringWithFormat:@"Gesture: %@", gestureName];
    self.statusLabel.text = @"Fluid Navigation Executed";
    self.statsLabel.text = @"Hardware Home Button & Gestures Unified";
    self.pulseDot.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0];
    self.blurView.layer.borderColor = [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:0.6].CGColor;
    [self.actionButton setTitle:@"Fluid" forState:UIControlStateNormal];
    self.actionButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:0.95];

    if (!self.isVisible) {
        self.hidden = NO;
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeTranslation(0, -60.0);

        [UIView animateWithDuration:0.5
                              delay:0.0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0.4
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
            self.alpha = 1.0;
            self.transform = CGAffineTransformIdentity;
        } completion:nil];
    }

    self.autoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:3.5 target:self selector:@selector(autoDismiss) userInfo:nil repeats:NO];
}

- (void)handleActionTapped {
    [self.autoDismissTimer invalidate];

    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [feedback prepare];
        [feedback impactOccurred];
    }

    [self dismissAnimated:YES];
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
