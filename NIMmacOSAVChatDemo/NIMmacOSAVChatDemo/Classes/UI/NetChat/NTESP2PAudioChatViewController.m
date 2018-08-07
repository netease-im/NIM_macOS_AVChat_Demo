//
//  NTESP2PAudioChatViewController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESP2PAudioChatViewController.h"
#import "NTESP2PVideoChatViewController.h"
#import "NSView+NTESToast.h"
#import "NTESWindowContext.h"

@interface NTESP2PAudioChatViewController ()
@property (weak) IBOutlet NSTextField *peerLabel;
@property (weak) IBOutlet NSTextField *waitingLabel;
@property (weak) IBOutlet NSTextField *durationLabel;
@property (weak) IBOutlet NSButton *micMuteBtn;
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *hangUpBtn;
@property (weak) IBOutlet NSButton *switchModeBtn;
@property (weak) IBOutlet NSImageView *bgView;
@property (weak) IBOutlet NSTextField *miclabel;
@property (weak) IBOutlet NSTextField *hangupLabel;
@property (assign) BOOL micMute;

@end

@implementation NTESP2PAudioChatViewController
- (instancetype)initWithCallInfo:(NTESNetCallChatInfo *)callInfo{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.callInfo = callInfo;
        [[NIMAVChatSDK sharedSDK].netCallManager switchType:NIMNetCallMediaTypeAudio];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.callInfo.callType = NIMNetCallTypeAudio;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)viewWillAppear
{
    [super viewWillAppear];
}

- (void)setUpUI
{
    NSMutableParagraphStyle *pghStyle = [[NSMutableParagraphStyle alloc] init];
    pghStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *dicAtt = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                             NSParagraphStyleAttributeName : pghStyle,
                             NSFontAttributeName :   [NSFont systemFontOfSize:13]};
    self.switchModeBtn.attributedTitle = [[NSAttributedString alloc] initWithString:@"切换为视频通话" attributes:dicAtt];
    
    self.bgView.imageScaling = NSImageScaleAxesIndependently;
    self.bgView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bgView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bgView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bgView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bgView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];

}

- (IBAction)micMute:(id)sender {
    _micMute = !_micMute;
    [self.micMuteBtn setImage:[NSImage imageNamed:!_micMute ? @"mic_on_n":@"mic_n"]];
    [self.micMuteBtn setAlternateImage:[NSImage imageNamed:!_micMute ? @"mic_on_p":@"mic_p"]];
    [[NIMAVChatSDK sharedSDK].netCallManager setMute:_micMute];
}

- (IBAction)cancel:(id)sender {
    [self hangup];
}

- (IBAction)hangUp:(id)sender {
    [self hangup];
}

- (IBAction)switchChatMode:(id)sender {
    [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeToVideo];
    [self waitingForSwitchToVideoInterface];
}

- (void)startInterface
{
    self.peerLabel.hidden = NO;
    self.waitingLabel.hidden = NO;
    self.durationLabel.hidden = YES;
    self.micMuteBtn.hidden = YES;
    self.cancelBtn.hidden = NO;
    self.hangUpBtn.hidden = YES;
    self.durationLabel.hidden = YES;
    self.switchModeBtn.hidden = YES;
    self.hangupLabel.hidden = YES;
    self.miclabel.hidden = YES;
    self.peerLabel.stringValue  = self.callInfo.callee;
}

- (void)connectingInterface
{
    self.peerLabel.hidden = NO;
    self.waitingLabel.hidden = YES;
    self.durationLabel.hidden = NO;
    self.micMuteBtn.hidden = NO;
    self.cancelBtn.hidden = YES;
    self.hangUpBtn.hidden = NO;
    self.durationLabel.hidden = NO;
    self.micMuteBtn.enabled = YES;
    self.hangUpBtn.enabled = YES;
    self.switchModeBtn.hidden = NO;
    self.hangupLabel.hidden = NO;
    self.miclabel.hidden = NO;
    self.peerLabel.stringValue  = self.callInfo.callee;
}

- (void)hangupInterface
{
    self.waitingLabel.hidden = YES;
    self.durationLabel.hidden = YES;
    self.micMuteBtn.hidden = YES;
    self.cancelBtn.hidden = YES;
    self.hangUpBtn.hidden = YES;
    self.hangupLabel.hidden = YES;
    self.miclabel.hidden = YES;
    self.peerLabel.hidden = YES;
    self.waitingLabel.hidden = YES;
    self.switchModeBtn.hidden = YES;
    self.durationLabel.hidden = NO;
    self.durationLabel.stringValue = @"挂断中";
}

- (void)waitingForSwitchToVideoInterface
{
    self.micMuteBtn.enabled = NO;
    self.hangUpBtn.enabled = NO;
    self.durationLabel.hidden = YES;
    self.waitingLabel.hidden = NO;
    self.waitingLabel.stringValue = @"等待对方切换摄像头\n...";
}

- (void)videoCallingInterface{
    NTESP2PVideoChatViewController *vc = [[NTESP2PVideoChatViewController alloc]initWithCallInfo:self.callInfo];
    self.view.window.contentViewController = vc;
}

- (void)onControl:(UInt64)callID from:(NSString *)user type:(NIMNetCallControlType)control
{
    [super onControl:callID from:user type:control];
    switch (control) {
        case NIMNetCallControlTypeToVideo:
            [self onResponseVideoMode];
            break;
        case NIMNetCallControlTypeAgreeToVideo:
            [self videoCallingInterface];
            break;
        case NIMNetCallControlTypeRejectToVideo:
            // 对方拒绝
        {
            self.waitingLabel.stringValue = @"对方拒绝切换为视频聊天";
            self.waitingLabel.hidden = NO;
            self.durationLabel.hidden = YES;
            __weak typeof(self) wself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wself connectingInterface];
            });
        }
            break;

        default:
            break;
    }
}

- (void)onResponseVideoMode{
    //提示是否需要切换
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"接听"];
    [alert addButtonWithTitle:@"拒绝"];
    [alert setMessageText:@"对方邀请你开始视频通话"];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if(returnCode == NSAlertFirstButtonReturn){
            [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeAgreeToVideo];
            [self videoCallingInterface];
        }else if(returnCode == NSAlertSecondButtonReturn){
            [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeRejectToVideo];
        }
    }];
}

- (void)onNTESTimerFired:(NTESTimerHolder *)holder
{
    [super onNTESTimerFired:holder];
    self.durationLabel.stringValue = self.durationDesc;
}


#pragma mark -  Misc
- (NSString*)durationDesc{
    if (!self.callInfo.startTime) {
        return @"";
    }
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = time - self.callInfo.startTime;
    return [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
}

@end
