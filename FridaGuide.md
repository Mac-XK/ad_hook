# 使用Frida分析iOS应用广告的指南

本指南介绍如何使用Frida工具分析iOS应用中的广告类和方法，以便更好地编写定制化的广告拦截hook。

## 准备工作

1. 安装Frida：
   ```bash
   pip install frida-tools
   ```

2. 在越狱设备上安装Frida服务器：
   - 从[Frida发布页面](https://github.com/frida/frida/releases)下载适合您设备的frida-server
   - 将其上传到设备并赋予执行权限
   - 运行frida-server

## 基本分析步骤

### 1. 列出设备上的应用

```bash
frida-ps -U
```

### 2. 附加到目标应用

```bash
frida -U [应用Bundle ID或进程名]
```

### 3. 使用JavaScript进行分析

以下是一些有用的Frida脚本示例：

#### 查找包含"Ad"或"广告"的类

```javascript
// save as find_ad_classes.js
setTimeout(function() {
    console.log("[*] 开始查找广告相关类...");
    var classes = ObjC.classes;
    var adClasses = [];
    
    for (var className in classes) {
        if (className.toLowerCase().indexOf("ad") !== -1 || 
            className.indexOf("广告") !== -1 ||
            className.indexOf("Banner") !== -1 ||
            className.indexOf("Interstitial") !== -1 ||
            className.indexOf("Rewarded") !== -1) {
            adClasses.push(className);
        }
    }
    
    console.log("[*] 找到 " + adClasses.length + " 个可能的广告相关类:");
    adClasses.sort().forEach(function(className) {
        console.log(className);
    });
}, 1000);
```

运行脚本：
```bash
frida -U -l find_ad_classes.js [应用Bundle ID]
```

#### 跟踪广告类的方法调用

```javascript
// save as trace_ad_methods.js
if (ObjC.available) {
    try {
        var className = "AdManager"; // 替换为您要跟踪的广告类名
        var methods = ObjC.classes[className].$ownMethods;
        
        console.log("[*] 开始跟踪 " + className + " 的方法:");
        
        methods.forEach(function(method) {
            var implementation = ObjC.classes[className][method];
            Interceptor.attach(implementation.implementation, {
                onEnter: function(args) {
                    console.log("[+] 调用: " + className + " -> " + method);
                    
                    // 打印参数（如果是对象类型）
                    if (method.indexOf(":") !== -1) {
                        var params = method.split(":");
                        for (var i = 1; i < params.length; i++) {
                            if (args[i+1]) {
                                var obj = ObjC.Object(args[i+1]);
                                console.log("    参数 " + (i) + ": " + obj);
                            }
                        }
                    }
                },
                onLeave: function(retval) {
                    if (retval) {
                        var obj = ObjC.Object(retval);
                        console.log("    返回值: " + obj);
                    }
                    console.log("");
                }
            });
        });
    } catch (e) {
        console.log("[!] 异常: " + e.message);
    }
} else {
    console.log("Objective-C Runtime 不可用");
}
```

运行脚本：
```bash
frida -U -l trace_ad_methods.js [应用Bundle ID]
```

#### 监控广告SDK初始化

```javascript
// save as monitor_ad_sdk.js
if (ObjC.available) {
    // 监控常见广告SDK初始化方法
    
    // Google AdMob
    try {
        var GADMobileAds = ObjC.classes.GADMobileAds;
        Interceptor.attach(GADMobileAds["+ sharedInstance"].implementation, {
            onEnter: function(args) {
                console.log("[+] GADMobileAds.sharedInstance 被调用");
            }
        });
        
        Interceptor.attach(GADMobileAds["- startWithCompletionHandler:"].implementation, {
            onEnter: function(args) {
                console.log("[+] GADMobileAds.startWithCompletionHandler: 被调用");
            }
        });
    } catch (e) {
        console.log("[!] Google AdMob SDK 未找到或方法不存在");
    }
    
    // 穿山甲
    try {
        var BUAdSDKManager = ObjC.classes.BUAdSDKManager;
        Interceptor.attach(BUAdSDKManager["+ setupWithAppId:"].implementation, {
            onEnter: function(args) {
                var appId = ObjC.Object(args[2]);
                console.log("[+] BUAdSDKManager.setupWithAppId: 被调用，AppID: " + appId);
            }
        });
    } catch (e) {
        console.log("[!] 穿山甲 SDK 未找到或方法不存在");
    }
    
    // 优量汇
    try {
        var GDTSDKConfig = ObjC.classes.GDTSDKConfig;
        Interceptor.attach(GDTSDKConfig["+ setupWithAppId:"].implementation, {
            onEnter: function(args) {
                var appId = ObjC.Object(args[2]);
                console.log("[+] GDTSDKConfig.setupWithAppId: 被调用，AppID: " + appId);
            }
        });
    } catch (e) {
        console.log("[!] 优量汇 SDK 未找到或方法不存在");
    }
    
    console.log("[*] 广告SDK监控已设置");
} else {
    console.log("Objective-C Runtime 不可用");
}
```

运行脚本：
```bash
frida -U -l monitor_ad_sdk.js [应用Bundle ID]
```

## 高级分析技巧

### 动态修改广告SDK行为

```javascript
// save as modify_ad_behavior.js
if (ObjC.available) {
    // 示例：修改广告可用性检查方法
    try {
        var AdManager = ObjC.classes.AdManager;
        Interceptor.replace(AdManager["- isAdAvailable"].implementation, new NativeCallback(function() {
            console.log("[+] 拦截 isAdAvailable 调用，返回 false");
            return 0; // 返回NO/false
        }, 'bool', ['pointer', 'pointer']));
        
        console.log("[*] 已替换 AdManager.isAdAvailable 方法");
    } catch (e) {
        console.log("[!] 替换方法失败: " + e.message);
    }
} else {
    console.log("Objective-C Runtime 不可用");
}
```

### 查找广告相关视图控制器

```javascript
// save as find_ad_viewcontrollers.js
if (ObjC.available) {
    // 监控视图控制器的呈现
    var UIViewController = ObjC.classes.UIViewController;
    
    Interceptor.attach(UIViewController["- presentViewController:animated:completion:"].implementation, {
        onEnter: function(args) {
            var viewController = ObjC.Object(args[2]);
            var className = viewController.$className;
            
            // 检查是否可能是广告视图控制器
            if (className.toLowerCase().indexOf("ad") !== -1 || 
                className.indexOf("广告") !== -1 ||
                className.indexOf("Banner") !== -1 ||
                className.indexOf("Interstitial") !== -1 ||
                className.indexOf("Rewarded") !== -1 ||
                className.indexOf("Splash") !== -1) {
                
                console.log("[+] 检测到可能的广告视图控制器:");
                console.log("    类名: " + className);
                console.log("    描述: " + viewController.toString());
                
                // 打印视图层次结构
                setTimeout(function() {
                    try {
                        var view = viewController.view();
                        console.log("    视图层次: " + view.recursiveDescription().toString());
                    } catch (e) {
                        console.log("    无法获取视图层次: " + e.message);
                    }
                }, 1000); // 延迟1秒，确保视图已加载
            }
        }
    });
    
    console.log("[*] 视图控制器监控已设置");
} else {
    console.log("Objective-C Runtime 不可用");
}
```

## 从Frida分析到Logos Hook

一旦您通过Frida确定了需要hook的类和方法，就可以在Tweak.xm中编写相应的Logos代码。

示例转换：

Frida发现的类和方法:
```
类名: AdManagerImpl
方法: - (void)loadAd
方法: - (BOOL)isAdAvailable
方法: - (void)showAdWithCompletion:(id)completion
```

对应的Logos代码:
```objective-c
%hook AdManagerImpl

- (void)loadAd {
    NSLog(@"[AdHook] 拦截广告加载");
    // 不调用原始实现
    return;
}

- (BOOL)isAdAvailable {
    NSLog(@"[AdHook] 拦截广告可用性检查");
    return NO; // 返回广告不可用
}

- (void)showAdWithCompletion:(id)completion {
    NSLog(@"[AdHook] 拦截广告展示");
    
    // 直接调用完成回调
    if (completion && [completion respondsToSelector:@selector(invoke)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [completion invoke];
        });
    }
    
    // 不调用原始实现
}

%end
```

## 总结

使用Frida进行动态分析可以帮助您:

1. 发现应用中使用的广告SDK和类
2. 分析广告加载和展示的流程
3. 确定需要hook的关键方法
4. 测试不同hook策略的效果

通过这些信息，您可以编写更加精确和有效的Logos hook代码，实现更好的广告拦截效果。 