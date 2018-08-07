# macOSAVChatDemo 源码导读 

## <span id="工程概述">工程概述</span>
网易云信SDK支持 iOS 、 Android 、 Windows 、 macOS 等多个平台，macOSAVChatDemo主要集成了网易云信macOS SDK，主要展示了1对1音频、1对1视频通话、多人音视频通话能力。
 

macOSAVChatDemo主要演示的功能有

 * 1对1音频通话发起、接听、拒绝、挂断等功能
 
 * 1对1视频通话发起、接听、拒绝、挂断等功能
 
 * 音频、视频通话模式切换功能
 
 * 多人音视频通话加入、离开等功能
 
 * 视频通话时一键美颜功能
 
 * 打开关闭摄像头
 
 * 静音/静音麦克风


## <span id="目录结构">目录结构</span>

```
└── NIMmacOSAVChatDemo/Classes                 # 云信 macOS 音视频工程
    ├── UI                                     # UI 界面交互层
    ├── Manager                                # 业务管理层
    ├── Category                               # Category 工具
    ├── Config                                 # Demo 相关配置
    └── Util                                   # 一些公共类
```

* UI 层  ：包括登录界面，点对点音视频发起界面，通话界面，多人音视频通话界面。
* Manager 层  ：包括登录，日志，通知等管理类。

## <span id="UI界面交互层介绍"> UI界面交互层介绍</span>

UI 界面交互层  ：包括登录及音视频通话两大功能的界面交互逻辑。

* 登录 `NTESLoginController` 包含登陆相关界面交互逻辑。
* 音视频通话
	* 音视频通话接听 `NTESChatNotificationController` 包含点对点及多人接听相关界面交互逻辑。
	* 点对点音视频通话 `NTESP2PChatViewController` 包含点对点发起及通话相关界面交互逻辑。
	* 多人音视频通话 `NTESMeetingChatViewController` 包含多人通话相关界面交互逻辑。

## <span id="程序运行">程序运行</span>

* 运行环境：macOS 10.12及以上

* 开发语言：Objective-C

* 登录账号获取：请在网易云信官网 [即时通讯PC Demo](https://yunxin.163.com/im-sdk-demo)、[AOS Demo](https://yunxin.163.com/im-sdk-demo)、[iOS Demo](https://yunxin.163.com/im-sdk-demo)、[Web Demo](https://yunxin.163.com/im-sdk-demo)注册账号，用注册成功的账号登录macOSAVChatDemo

## <span id="相关源码参考">相关能力开发文档源码参考</span>


* [网易云信NIM Windows(PC) Demo ](https://github.com/netease-im/NIM_PC_Demo) 

* [网易云信Android demo](https://github.com/netease-im/NIM_Android_Demo) 

* [网易云信web demo](https://github.com/netease-im/NIM_Web_Demo) 

* [网易云信IM DEMO 小程序 Demo ](https://github.com/netease-im/NIM_Web_Weapp_Demo) 

* [网易云信Android音视频组件](https://github.com/netease-im/NIM_Android_AVChatKit) 


## <span id="Q&A">Q&A</span>

Q： macOSAVChatDemo的登录账号该怎么获取呢？

A： 在网易云信官网 [即时通讯PC Demo](https://yunxin.163.com/im-sdk-demo)、[ AOS Demo](https://yunxin.163.com/im-sdk-demo)、[ iOS Demo](https://yunxin.163.com/im-sdk-demo)、[Web Demo](https://yunxin.163.com/im-sdk-demo)注册账号，然后用该账号登录macOSAVChatDemo，不久将在Demo上增加注册账号源码，尽情期待。

Q： macOSAVChatDemo除了和macOSAVChatDemo互通外，可以和其他端互通演示吗？

A： 目前 点对点macOSAVChatDemo除了和macOSAVChatDemo互通外，还可以和[即时通讯PC Demo](https://yunxin.163.com/im-sdk-demo)、[ AOS Demo](https://yunxin.163.com/im-sdk-demo)、[iOS  Demo](https://yunxin.163.com/im-sdk-demo)、[Web  Demo](https://yunxin.163.com/im-sdk-demo) 中的音视频通话互通；多人macOSAVChatDemo除了和macOSAVChatDemo互通外，还可以和[即时通讯PC Demo](https://yunxin.163.com/im-sdk-demo)、[ AOS Demo](https://yunxin.163.com/im-sdk-demo)、[ iOS  Demo](https://yunxin.163.com/im-sdk-demo)、[Web  Demo](https://yunxin.163.com/im-sdk-demo) 中的音视频通话互通，目前还没有在macOSAVChatDemo作音视频通话发起，不久将在Demo上增加此功能，尽情期待。

Q： 如何在源码中发现bug、集成过程中、售前、售后遇到问题该怎么办呢？

A： 如果发现源码中发现bug，请提交到[Issue](https://github.com/netease-im/NIM_macOS_AVChat_Demo/issues)，如果在集成过程中遇到问题，请到[易云社区](https://yunxin.163.com/dev-blog/question)提问，如果售前咨询，请联系4009-000-123，如果售后遇到问题，请提交[工单](http://app.netease.im/index#/issue/submit)，我们会即时响应处理。

