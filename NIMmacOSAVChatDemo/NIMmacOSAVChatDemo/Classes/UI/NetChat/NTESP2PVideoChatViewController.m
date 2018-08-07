//
//  NTESP2PChatViewController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/4.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESP2PVideoChatViewController.h"
#import "NTESRemoteVideoView.h"
#import "NTESWindowContext.h"
#import "NTESP2PAudioChatViewController.h"

@interface NTESP2PVideoChatViewController ()<NIMNetCallManagerDelegate>

@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *micMuteBtn;
@property (weak) IBOutlet NSButton *cameraBtn;
@property (weak) IBOutlet NSButton *beautyBtn;
@property (weak) IBOutlet NSButton *hangUpBtn;
@property (weak) IBOutlet NSView *smallView;
@property (weak) IBOutlet NSTextField *waitingLabel;
@property (weak) IBOutlet NSTextField *peerLabel;
@property (weak) IBOutlet NSTextField *durationLabel;
@property (weak) IBOutlet NSButton *switchModeBtn;
@property (weak) IBOutlet NSImageView *bgView;
@property (weak) IBOutlet NSTextField *micLabel;
@property (weak) IBOutlet NSTextField *cameraLabel;
@property (weak) IBOutlet NSTextField *beautifyLabel;
@property (weak) IBOutlet NSTextField *hangupLabel;
@property (weak) IBOutlet NTESRemoteVideoView *bigView;

@property (nonatomic,weak) NSView *localPreView;
@property (nonatomic,assign) BOOL isCaller;
@property (nonatomic,assign) BOOL micMute;
@property (nonatomic,assign) BOOL cameraDisabled;
@property (nonatomic,assign) BOOL beautified;

@end

@implementation NTESP2PVideoChatViewController
- (instancetype)initWithCallInfo:(NTESNetCallChatInfo *)callInfo{
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.callInfo = callInfo;
        if (!self.localPreView) {
            self.localPreView = [NIMAVChatSDK sharedSDK].netCallManager.localPreview;
        }
        [[NIMAVChatSDK sharedSDK].netCallManager switchType:NIMNetCallMediaTypeVideo];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.callInfo.callType = NIMNetCallTypeVideo;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    [self setUpUI];
    if (self.localPreView) {
        self.localPreView.frame = self.smallView.bounds;
        [self.smallView addSubview:self.localPreView];
    }
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
    self.switchModeBtn.attributedTitle = [[NSAttributedString alloc] initWithString:@"切换为音频通话" attributes:dicAtt];

    self.bigView.wantsLayer = YES;
    self.bigView.layer.backgroundColor = NSColorFromRGBA(0x000000, 0.78).CGColor;
}

#pragma mark - User Interaction
- (IBAction)hangUp:(id)sender {
    [self hangup];
}

- (IBAction)cancel:(id)sender {
    [self hangup];
}

- (IBAction)switchChatModel:(id)sender{
    [[NIMAVChatSDK sharedSDK].netCallManager control:self.callInfo.callID type:NIMNetCallControlTypeToAudio];
    [self switchToAudio];
}

- (IBAction)micMute:(id)sender {
    _micMute = !_micMute;
    [self.micMuteBtn setImage:[NSImage imageNamed:!_micMute ? @"mic_on_n":@"mic_n"]];
    [self.micMuteBtn setAlternateImage:[NSImage imageNamed:!_micMute ? @"mic_on_p":@"mic_p"]];
    [[NIMAVChatSDK sharedSDK].netCallManager setMute:_micMute];
}

- (IBAction)disabledCamera:(id)sender {
    _cameraDisabled = !_cameraDisabled;
    [self.cameraBtn setImage:[NSImage imageNamed:_cameraDisabled ? @"camera_n":@"camera_on_n"]];
    [self.cameraBtn setAlternateImage:[NSImage imageNamed:!_cameraDisabled ? @"camera_p":@"camera_on_p"]];
    [[NIMAVChatSDK sharedSDK].netCallManager setCameraDisable:_cameraDisabled];
    if (_cameraDisabled) {
        [self.localPreView removeFromSuperview];
    }
}

- (IBAction)beautify:(id)sender {
    _beautified = !_beautified;
    [self.beautyBtn setImage:[NSImage imageNamed:_beautified ? @"beautify_on_n":@"beautify_n"]];
    [self.beautyBtn setAlternateImage:[NSImage imageNamed:_beautified ? @"beautify_on_p":@"beautify_p"]];
    
    [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:_beautified ? NIMNetCallFilterTypeZiran : NIMNetCallFilterTypeNormal];
}

#pragma mark - Call
- (void)startByCallee
{
    [super startByCallee];
}

#pragma mark - Interface

- (void)startInterface{
    self.bgView.hidden = NO;
    self.hangUpBtn.hidden  = YES;
    self.micMuteBtn.hidden  = YES;
    self.cameraBtn.hidden  = YES;
    self.beautyBtn.hidden  = YES;
    self.durationLabel.hidden = YES;
    self.peerLabel.stringValue  = self.callInfo.callee;
    self.micLabel.hidden = YES;
    self.cameraLabel.hidden = YES;
    self.beautifyLabel.hidden = YES;
    self.hangupLabel.hidden = YES;

}

- (void)connectingInterface{
    self.peerLabel.hidden = YES;
    self.waitingLabel.hidden = YES;
    self.cancelBtn.hidden = YES;
    self.hangUpBtn.hidden  = NO;
    self.micMuteBtn.hidden  = NO;
    self.cameraBtn.hidden  = NO;
    self.beautyBtn.hidden  = NO;
    self.durationLabel.hidden = NO;
    self.bgView.hidden = YES;
    self.micLabel.hidden = NO;
    self.cameraLabel.hidden = NO;
    self.beautifyLabel.hidden = NO;
    self.hangupLabel.hidden = NO;
}

- (void)hangupInterface
{
    self.hangUpBtn.hidden  = YES;
    self.micMuteBtn.hidden  = YES;
    self.cameraBtn.hidden  = YES;
    self.beautyBtn.hidden  = YES;
    self.micLabel.hidden = YES;
    self.cameraLabel.hidden = YES;
    self.beautifyLabel.hidden = YES;
    self.hangupLabel.hidden = YES;
    self.peerLabel.hidden = YES;
    self.waitingLabel.hidden = YES;
    self.durationLabel.hidden = NO;
    self.bgView.hidden = NO;
    self.durationLabel.stringValue = @"挂断中";
}

- (void)audioCallingInterface{
    NTESP2PAudioChatViewController *vc = [[NTESP2PAudioChatViewController alloc]initWithCallInfo:self.callInfo];
    self.view.window.contentViewController = vc;
}

- (void)switchToAudio{
    [self audioCallingInterface];
}

- (void)onControl:(UInt64)callID from:(NSString *)user type:(NIMNetCallControlType)control
{
    [super onControl:callID from:user type:control];
    switch (control) {
        case NIMNetCallControlTypeToAudio:
            [self switchToAudio];
            break;
            
        default:
            break;
    }
}

#pragma mark - NIMNetCallManagerDelegate
- (void)onLocalDisplayviewReady:(NSView *)displayView
{
    if (self.localPreView) {
        [self.localPreView removeFromSuperview];
    }
    
    self.localPreView = displayView;
    displayView.frame = self.smallView.bounds;
    
    [self.smallView addSubview:displayView];
}

- (void)onRemoteVideo:(CMSampleBufferRef)sampleBuffer from:(NSString *)user
{
    [self.bigView displaySampleBuffer:sampleBuffer];
}

- (void)onNTESTimerFired:(NTESTimerHolder *)holder{
    [super onNTESTimerFired:holder];
    self.durationLabel.stringValue = self.durationDesc;
}

- (NSString*)durationDesc{
    if (!self.callInfo.startTime) {
        return @"";
    }
    NSTimeInterval time = [NSDate date].timeIntervalSince1970;
    NSTimeInterval duration = time - self.callInfo.startTime;
    return [NSString stringWithFormat:@"%02d:%02d",(int)duration/60,(int)duration%60];
}

@end
