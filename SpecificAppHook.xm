// 针对特定应用的广告Hook示例
// 此示例假设目标应用为某视频应用

#import <UIKit/UIKit.h>

// 应用特定的广告视图控制器
%hook AppAdViewController

- (void)viewDidLoad {
    %orig;
    NSLog(@"[AdHook] 拦截特定应用广告控制器: AppAdViewController");
    
    // 延迟一小段时间后关闭广告
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:NO completion:nil];
    });
}

- (void)loadAdWithParameters:(id)parameters {
    NSLog(@"[AdHook] 拦截广告加载: loadAdWithParameters");
    // 不调用原始实现
    return;
}

%end

// 应用特定的广告管理器
%hook AppAdManager

+ (instancetype)sharedInstance {
    NSLog(@"[AdHook] 获取广告管理器单例");
    return %orig;
}

- (void)initWithAppId:(NSString *)appId {
    NSLog(@"[AdHook] 拦截广告管理器初始化: %@", appId);
    %orig; // 允许初始化但不加载广告
}

- (BOOL)isAdAvailable {
    NSLog(@"[AdHook] 拦截广告可用性检查");
    return NO; // 返回广告不可用
}

- (void)loadAd {
    NSLog(@"[AdHook] 拦截广告加载");
    // 不调用原始实现
}

- (void)showAdInViewController:(UIViewController *)viewController completion:(void(^)(BOOL success, NSError *error))completion {
    NSLog(@"[AdHook] 拦截广告展示");
    
    // 直接调用完成回调，模拟成功
    if (completion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(YES, nil);
        });
    }
    
    // 不调用原始实现
}

%end

// 应用特定的激励广告处理
%hook AppRewardedAd

- (void)loadWithCompletion:(void(^)(BOOL success, NSError *error))completion {
    NSLog(@"[AdHook] 拦截激励广告加载");
    
    // 直接调用完成回调，模拟成功
    if (completion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(YES, nil);
        });
    }
    
    // 不调用原始实现
}

- (void)showFromViewController:(UIViewController *)viewController completion:(void(^)(BOOL watched, NSError *error))completion {
    NSLog(@"[AdHook] 拦截激励广告展示");
    
    // 直接调用完成回调，模拟已观看
    if (completion) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            completion(YES, nil);
        });
    }
    
    // 不调用原始实现
}

%end

// 应用特定的广告视图
%hook AppBannerAdView

- (instancetype)initWithFrame:(CGRect)frame {
    NSLog(@"[AdHook] 拦截广告视图初始化");
    id original = %orig;
    if (original) {
        // 设置尺寸为0
        [original setFrame:CGRectZero];
        [original setHidden:YES];
    }
    return original;
}

- (void)loadAd {
    NSLog(@"[AdHook] 拦截广告视图加载");
    // 不调用原始实现
}

%end

// 构造函数
%ctor {
    NSLog(@"[AdHook] 特定应用广告拦截插件已加载");
    
    // 获取当前应用的Bundle ID
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"[AdHook] 当前应用Bundle ID: %@", bundleID);
    
    // 检查是否为目标应用
    if ([bundleID isEqualToString:@"com.example.targetapp"]) {
        NSLog(@"[AdHook] 目标应用已检测，启用特定Hook");
    } else {
        NSLog(@"[AdHook] 非目标应用，不启用特定Hook");
        // 可以在这里禁用特定的Hook
    }
} 