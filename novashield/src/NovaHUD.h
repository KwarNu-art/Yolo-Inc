#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NovaRescueActionHandler)(void);

@interface NovaHUD : UIWindow

@property (nonatomic, copy, nullable) NovaRescueActionHandler onRescueTapped;
@property (nonatomic, assign, readonly) BOOL isVisible;

+ (instancetype)sharedInstance;
- (void)showWithCPU:(float)cpuPercent memoryMB:(float)memoryMB isGaming:(BOOL)isGaming;
- (void)showBootBanner;
- (void)showChargingHUDWithLevel:(int)batteryLevel isFastCharge:(BOOL)isFastCharge;
- (void)dismissAnimated:(BOOL)animated;
- (void)flashSuccessWithStatus:(NSString *)statusText;

@end

NS_ASSUME_NONNULL_END
