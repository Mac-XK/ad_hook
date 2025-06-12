// 广告Hook示例 - 通用广告SDK拦截

// 导入必要的头文件
#import <UIKit/UIKit.h>

// Hook UIViewController，用于拦截广告视图控制器
%hook UIViewController

// 拦截viewDidAppear方法
- (void)viewDidAppear:(BOOL)animated {
    %orig; // 调用原始实现
    
    // 检测常见广告视图控制器类名
    NSString *className = NSStringFromClass([self class]);
    NSArray *adClassNames = @[
        @"AdViewController", 
        @"InterstitialAdViewController",
        @"BannerAdViewController",
        @"RewardedAdViewController",
        @"SplashAdViewController"
    ];
    
    for (NSString *adClassName in adClassNames) {
        if ([className containsString:adClassName]) {
            NSLog(@"[AdHook] 检测到广告视图控制器: %@", className);
            
            // 移除广告视图控制器
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:nil];
            });
            
            break;
        }
    }
}

%end

// Hook 常见的广告视图类
%hook UIView

- (void)didMoveToSuperview {
    %orig;
    
    // 检查视图类名是否包含广告相关字符串
    NSString *className = NSStringFromClass([self class]);
    NSArray *adViewKeywords = @[@"AdView", @"BannerView", @"InterstitialView", @"RewardedAdView"];
    
    BOOL isAdView = NO;
    for (NSString *keyword in adViewKeywords) {
        if ([className containsString:keyword]) {
            isAdView = YES;
            break;
        }
    }
    
    // 如果是广告视图，则隐藏它
    if (isAdView) {
        NSLog(@"[AdHook] 检测到广告视图: %@", className);
        self.hidden = YES;
        self.alpha = 0.0;
        
        // 移除广告视图
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    }
}

%end

// Hook 常见的广告加载方法
%hook NSObject

// 拦截广告加载方法
- (void)loadAd {
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"[AdHook] 拦截广告加载: %@ - loadAd", className);
    // 不调用原始实现，直接返回
    return;
}

- (void)loadAds {
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"[AdHook] 拦截广告加载: %@ - loadAds", className);
    // 不调用原始实现，直接返回
    return;
}

- (void)showAd {
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"[AdHook] 拦截广告展示: %@ - showAd", className);
    // 不调用原始实现，直接返回
    return;
}

- (void)showInterstitial {
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"[AdHook] 拦截插页式广告: %@ - showInterstitial", className);
    // 不调用原始实现，直接返回
    return;
}

- (void)showRewardedAd {
    NSString *className = NSStringFromClass([self class]);
    NSLog(@"[AdHook] 拦截激励广告: %@ - showRewardedAd", className);
    
    // 对于激励广告，我们可以模拟广告已观看完成，直接调用回调
    SEL rewardSelector = NSSelectorFromString(@"adDidEarnReward:");
    if ([self respondsToSelector:rewardSelector]) {
        NSLog(@"[AdHook] 模拟激励广告完成回调");
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:rewardSelector withObject:nil];
        #pragma clang diagnostic pop
    }
    
    // 不调用原始实现
    return;
}

%end

// 针对常见广告SDK的具体Hook

// 谷歌广告 (Google AdMob)
%hook GADMobileAds

+ (instancetype)sharedInstance {
    NSLog(@"[AdHook] 拦截 GADMobileAds sharedInstance");
    return %orig;
}

- (void)startWithCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"[AdHook] 拦截 GADMobileAds 初始化");
    if (completionHandler) {
        completionHandler();
    }
}

%end

// 穿山甲广告 (ByteDance)
%hook BUAdSDKManager

+ (void)setupWithAppId:(NSString *)appID {
    NSLog(@"[AdHook] 拦截 BUAdSDKManager setupWithAppId: %@", appID);
    // 允许初始化但不加载广告
    %orig;
}

%end

// 优量汇广告 (Tencent)
%hook GDTSDKConfig

+ (void)setupWithAppId:(NSString *)appId {
    NSLog(@"[AdHook] 拦截 GDTSDKConfig setupWithAppId: %@", appId);
    // 允许初始化但不加载广告
    %orig;
}

%end

// 构造函数
%ctor {
    NSLog(@"[AdHook] 广告拦截插件已加载");
} 