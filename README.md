# AdBlocker - iOS广告拦截Tweak

这是一个使用Logos语法编写的iOS广告拦截Tweak，可以拦截常见的广告SDK和广告展示。

## 功能特点

- 拦截常见广告视图控制器
- 隐藏和移除广告视图
- 拦截广告加载和展示方法
- 支持常见广告SDK（谷歌AdMob、穿山甲、优量汇等）
- 对于激励广告，模拟完成回调以获取奖励

## 安装要求

- 已越狱的iOS设备
- Theos开发环境

## 编译安装

1. 确保已安装Theos开发环境
2. 克隆此仓库
3. 进入项目目录
4. 执行以下命令编译和安装：

```bash
make
make package
make install
```

## 自定义

如果需要拦截其他广告SDK或广告方法，可以在`Tweak.xm`文件中添加相应的hook代码。

## 注意事项

- 此Tweak仅供学习和研究使用
- 请尊重开发者，支持正版应用
- 不同应用可能使用不同的广告SDK或自定义广告实现，可能需要针对性调整

## 工作原理

此Tweak通过以下方式拦截广告：

1. 识别并移除广告视图控制器
2. 隐藏和移除广告视图
3. 拦截常见的广告加载和展示方法
4. 针对特定广告SDK进行定制化处理

## 如何定制

要针对特定应用定制广告拦截，可以：

1. 使用Frida或其他工具分析应用中的广告类和方法
2. 在`Tweak.xm`中添加针对性的hook代码
3. 重新编译和安装Tweak 

---

# AdBlocker - iOS Ad Blocking Tweak

This is an iOS ad blocking tweak written using Logos syntax, capable of intercepting common ad SDKs and ad displays.

## Features

- Intercept common ad view controllers
- Hide and remove ad views
- Block ad loading and display methods
- Support for common ad SDKs (Google AdMob, ByteDance, Tencent Ad, etc.)
- For rewarded ads, simulate completion callbacks to receive rewards

## Requirements

- Jailbroken iOS device
- Theos development environment

## Compilation and Installation

1. Make sure Theos development environment is installed
2. Clone this repository
3. Enter the project directory
4. Execute the following commands to compile and install:

```bash
make
make package
make install
```

## Customization

If you need to block other ad SDKs or ad methods, you can add corresponding hook code in the `Tweak.xm` file.

## Notes

- This tweak is for learning and research purposes only
- Please respect developers and support official apps
- Different apps may use different ad SDKs or custom ad implementations, which may require specific adjustments

## How It Works

This tweak blocks ads through the following methods:

1. Identifying and removing ad view controllers
2. Hiding and removing ad views
3. Intercepting common ad loading and display methods
4. Custom handling for specific ad SDKs

## How to Customize

To customize ad blocking for specific applications, you can:

1. Use Frida or other tools to analyze ad classes and methods in the app
2. Add targeted hook code in `Tweak.xm`
3. Recompile and install the tweak 
