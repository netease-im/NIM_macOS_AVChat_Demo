//
//  NTESP2PChatViewController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESP2PChatViewController.h"
#import "NTESWindowContext.h"
#import "NTESTimerHolder.h"
#import <AVFoundation/AVFoundation.h>
#import "NSView+NTESToast.h"

#define DelaySelfStartControlTime 10
#define NoBodyResponseTimeOut 45


@interface NTESP2PChatViewController ()<NIMNetCallManagerDelegate,NTESTimerHolderDelegate>

@property (nonatomic, strong)NTESTimerHolder *timer;

@property (nonatomic, assign)BOOL responsed;

@property (nonatomic, assign)BOOL feedBacked;

@end

@implementation NTESP2PChatViewController

- (instancetype)initWithCallee:(NSString *)callee{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.peerUid = callee;
        self.callInfo.callee = callee;
        self.callInfo.caller = [[NIMSDK sharedSDK].loginManager currentAccount];
    }
    return self;
}

- (instancetype)initWithCaller:(NSString *)caller callId:(uint64_t)callID{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.peerUid = caller;
        self.callInfo.caller = caller;
        self.callInfo.callee = [[NIMSDK sharedSDK].loginManager currentAccount];
        self.callInfo.callID = callID;
    }
    return self;
}

- (instancetype)initWithNibName:(NSNibName)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _callInfo = [[NTESNetCallChatInfo alloc] init];
        _timer = [[NTESTimerHolder alloc]init];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    if (self.callInfo.isStart) {
        [self.timer startTimer:0.5 delegate:self repeats:YES];
        [self connectingInterface];
    }
    else
    {
        if (self.callInfo.callID) {
            [self startInterface];
            [self startByCallee];
        }
        
        else
        {
            [self startInterface];
            [self startByCaller];
        }
    }
}

- (void)viewWillAppear
{
    [NTESWindowContext sharedInstance].mainWindowController.window.styleMask = [NTESWindowContext sharedInstance].mainWindowController.window.styleMask | NSWindowStyleMaskResizable;
}

- (void)viewWillDisappear
{
    [self.player stop];
}

- (void)startByCaller{
    self.callInfo.isStart = YES;
    NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
    [self fillUserSetting:option];
    
    __weak typeof(self) wself = self;
    [[NIMAVChatSDK sharedSDK].netCallManager start:@[self.peerUid] type:self.callInfo.callType option:option completion:^(NSError *error, UInt64 callID) {
        wself.callInfo.callID = callID;
        if (!error &&  wself) {
            DDLogInfo(@"start p2p success");
            //十秒之后如果还是没有收到对方响应的control字段，则自己发起一个假的control，用来激活铃声
            NSTimeInterval delayTime = DelaySelfStartControlTime;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wself onControl:callID from:wself.callInfo.callee type:NIMNetCallControlTypeFeedabck];
            });
        }
        else
        {
            if (error) {
                DDLogInfo(@"start p2p failed");
                if (error.code == NIMRemoteErrorCodeNotExist) {
                    // 对方不在线
                    [wself.view showToast:@"账号不存在"];
                }
                else if (error.code == NIMAVRemoteErrorCodeCalleeOffline)
                {
                    [wself.view showToast:@"对方不在线"];
                }
                else
                {
                    [wself.view showToast:[NSString stringWithFormat:@"通话失败 code :%zd",error.code]];
                }
                [[NIMAVChatSDK sharedSDK].netCallManager hangup:callID];
            }else{
                //说明在start的过程中把页面关了。。
                [[NIMAVChatSDK sharedSDK].netCallManager hangup:callID];
            }
            [wself dismiss:YES];
        }
    }];
}

- (void)startByCallee{
    self.callInfo.isStart = YES;
    [self response];
}

- (void)hangup{
    [[NIMAVChatSDK sharedSDK].netCallManager hangup:self.callInfo.callID];
    [self.timer stopTimer];
    [self hangupInterface];
    [self dismiss:YES];
}

- (void)response{
    
    NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
    [self fillUserSetting:option];
    __weak typeof(self) wself = self;
    
    [[NIMAVChatSDK sharedSDK].netCallManager response:self.callInfo.callID accept:YES option:option completion:^(NSError *error, UInt64 callID) {
        if (!error) {
            [wself connectingInterface];
        }else{
            [self dismiss:NO];
        }
    }];
}

- (void)startInterface
{
    //override
}

- (void)connectingInterface
{
    //override
}

- (void)hangupInterface
{
    //override
}

//铃声 - 正在呼叫请稍后
- (void)playConnnetRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_connect_chat_tip_sender" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

//铃声 - 接收方铃声
- (void)playReceiverRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_receiver" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 20;
    [self.player play];
}

//铃声 - 对方正在通话中
- (void)playOnCallRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_OnCall" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

//铃声 - 对方无人接听
- (void)playTimeoutRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_onTimer" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

//铃声 - 拨打方铃声
- (void)playSenderRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_sender" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 20;
    [self.player play];
}

//铃声 - 对方暂时无法接听
- (void)playHangUpRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_HangUp" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player play];
}

- (void)dismiss:(BOOL)delay
{
    if (delay) {
        __weak typeof(self) wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(wself)
            {
                [[NTESWindowContext sharedInstance] backToMainWindow];
            }
        });
    }
    else
    {
        [[NTESWindowContext sharedInstance] backToMainWindow];
    }
}

#pragma mark - NIMNetCallManagerDelegate
- (void)onCallEstablished:(UInt64)callID
{
    self.callInfo.startTime = [NSDate date].timeIntervalSince1970;
    [self.timer startTimer:0.5 delegate:self repeats:YES];
}

- (void)onHangup:(UInt64)callID by:(NSString *)user
{
    // 对方已挂断
    [self.view showToast:@"对方已挂断"];
    [self.player stop];
    [self dismiss:YES];
}

- (void)onResponse:(UInt64)callID from:(NSString *)callee accepted:(BOOL)accepted
{
    _responsed = YES;
    if (!accepted) {
        // 对方拒绝
        [self.view showToast:@"对方拒绝"];
        [self playHangUpRing];
        [self dismiss:YES];
    }else{
        [self.player stop];
        [self connectingInterface];
    }
}

- (void)onCallDisconnected:(UInt64)callID withError:(NSError *)error
{
    if (error) {
        // 通信断开
        [self.view showToast:@"通信断开"];
    }
    [self dismiss:YES];
}

- (void)onControl:(UInt64)callID from:(NSString *)user type:(NIMNetCallControlType)control
{
    switch (control) {
        case NIMNetCallControlTypeFeedabck:{
            if (!self.feedBacked && !self.responsed) {
                self.feedBacked = YES;
                [self playSenderRing];
                NSTimeInterval delayTime = NoBodyResponseTimeOut;
                __weak typeof(self) wself = self;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        // 无人接听
                        if(wself && !wself.responsed)
                        {
                            [wself.view showToast:@"无人接听"];
                            [wself playTimeoutRing];
                            [wself hangup];
                        }
                });
            }
            break;
        }
        case NIMNetCallControlTypeBusyLine: {
            // 对方正在通话中
            [self.view showToast:@"对方正在通话中"];
            [self playOnCallRing];
            [self hangup];
            break;
        }
        default:
            break;
    }
}

- (void)onResponsedByOther:(UInt64)callID
                  accepted:(BOOL)accepted{
    [self.view showToast:@"已在其他端处理"];
    [self dismiss:YES];
}

#pragma mark - Private
- (void)fillUserSetting:(NIMNetCallOption *)option
{
    NIMNetCallVideoCaptureParam *param = [[NIMNetCallVideoCaptureParam alloc] init];
    param.videoProcessorParam = [NIMNetCallVideoProcessorParam new];
    option.videoCaptureParam = param;
}

#pragma mark - NTESTimerHolderDelegate
- (void)onNTESTimerFired:(NTESTimerHolder *)holder
{
    //override by subclass
}

@end

@implementation NTESNetCallChatInfo
@end
