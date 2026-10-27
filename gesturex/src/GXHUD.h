#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GXHUD : UIWindow

@property (nonatomic, assign, readonly) BOOL isVisible;

+ (instancetype)sharedInstance;
- (void)showBootBanner;
- (void)showGestureTriggeredHUD:(NSString *)gestureName;
- (void)dismissAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
