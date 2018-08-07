//
//  NTESChatNotificationController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESChatNotificationController.h"
#import "NTESP2PAudioChatViewController.h"
#import "NTESP2PVideoChatViewController.h"
#import "NTESWindowContext.h"
#import "NTESTimerHolder.h"
#import "NTESMeetingChatViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSView+NTESToast.h"

#define NoBodyResponseTimeOut 45

@interface NTESChatNotificationController ()<NTESTimerHolderDelegate,NIMNetCallManagerDelegate>

@property (weak) IBOutlet NSTextField *peerLabel;
@property (weak) IBOutlet NSTextField *inviteLabel;
@property (weak) IBOutlet NSScrollView *collectionView;
@property (nonatomic,assign) BOOL calleeResponsed;
@property (nonatomic,assign) UInt64 callID;
@property (nonatomic,assign) NTESChatMode mode;
@property (nonatomic,strong) NSString *caller;
@property (nonatomic,strong) NSString *meetingName;
@property (nonatomic,strong) AVAudioPlayer *player;
@property (nonatomic,strong) NTESTimerHolder *calleeResponseTimer;
@property (nonatomic,strong) NTESMeetingInfo *meetingInfo;

@end

@implementation NTESChatNotificationController

- (instancetype)initWithChatMode:(NTESChatMode)chatMode caller:(NSString *)caller callID:(UInt64)callID;
{
    if (self = [super init]) {
        self.mode = chatMode;
        self.caller = caller;
        self.callID = callID;
        _calleeResponseTimer = [[NTESTimerHolder alloc]init];
        [_calleeResponseTimer startTimer:NoBodyResponseTimeOut delegate:self repeats:NO];
        [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    }
    return self;
}

- (instancetype)initWithMeetingInfo:(NTESMeetingInfo *)info caller:(NSString *)caller;
{
    if (self = [super init]) {
        self.mode = NTESChatModeMeeting;
        self.caller = caller;
        self.meetingInfo = info;
        [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    switch (self.mode) {
        case NTESChatModeAudioP2P:
        {
            [self audioP2PInterface];
        }
            break;
        case NTESChatModeVideoP2P:
        {
            [self videoP2PInterface];
        }
            break;
            
        case NTESChatModeMeeting:
        {
            [self meetingInterface];
        }
            break;
        default:
            break;
    }
    [self playReceiverRing];
}

- (void)viewWillDisappear
{
    [self.player stop];
}

- (void)audioP2PInterface
{
    self.peerLabel.stringValue = self.caller;
    self.inviteLabel.stringValue = @"邀请语音通话......";
}

- (void)videoP2PInterface
{
    self.peerLabel.stringValue = self.caller;
    self.inviteLabel.stringValue = @"邀请视频通话......";
}

- (void)meetingInterface
{
    self.peerLabel.stringValue = self.caller ? self.caller : @"群主";
    self.inviteLabel.stringValue = @"邀请你群组音视频通话......";
}

//铃声 - 接收方铃声
- (void)playReceiverRing{
    [self.player stop];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_receiver" withExtension:@"aac"];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.player.numberOfLoops = 20;
    [self.player play];
}

- (IBAction)refuse:(id)sender {
    _calleeResponsed = YES;
    
    if (self.mode != NTESChatModeMeeting) {
        [self refuseCall];
    }
    else
    {
        [self dismiss:NO];
    }
}

- (IBAction)accept:(id)sender {
    _calleeResponsed = YES;
    switch (self.mode) {
        case NTESChatModeAudioP2P:
        {
            NTESP2PAudioChatViewController *vc = [[NTESP2PAudioChatViewController alloc]initWithCaller:_caller callId:_callID];
            self.view.window.contentViewController = vc;
        }
            break;
        case NTESChatModeVideoP2P:
        {
            NTESP2PVideoChatViewController *vc = [[NTESP2PVideoChatViewController alloc]initWithCaller:_caller callId:_callID];
            self.view.window.contentViewController = vc;
        }
            break;
        case NTESChatModeMeeting:
        {
            NTESMeetingChatViewController *vc = [[NTESMeetingChatViewController alloc] initWithMeeting:_meetingInfo];
            self.view.window.contentViewController = vc;
        }
            break;
        default:
            break;
    }
}

- (void)refuseCall{
    [[NIMAVChatSDK sharedSDK].netCallManager response:_callID accept:NO option:nil completion:^(NSError *error, UInt64 callID) {
        if (!error) {
            [self dismiss:NO];
        }else{
            DDLogInfo(@"refuse call error %ld",error.code);
            [self dismiss:NO];
        }
    }];
}

- (void)onNTESTimerFired:(NTESTimerHolder *)holder{
    if (!_calleeResponsed) {
        [self refuseCall];
        // 无人接听
        [self.view showToast:@"无人接听"];
    }
}

- (void)onHangup:(UInt64)callID by:(NSString *)user
{
    // 对方已挂断
    [self.view showToast:@"对方已挂断"];
    [self.player stop];
    [self dismiss:NO];
}

- (void)onCallDisconnected:(UInt64)callID withError:(NSError *)error
{
    if (error) {
        // 通信断开
        [self.view showToast:@"通信断开"];
    }
    [self dismiss:YES];
}


- (void)onResponsedByOther:(UInt64)callID
                  accepted:(BOOL)accepted{
    [self.view showToast:@"已在其他端处理"];
    [self dismiss:YES];
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

- (void)dealloc
{
    [[NIMAVChatSDK sharedSDK].netCallManager removeDelegate:self];
}


@end
