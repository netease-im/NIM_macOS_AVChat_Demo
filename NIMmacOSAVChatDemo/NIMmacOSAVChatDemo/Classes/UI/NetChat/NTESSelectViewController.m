//
//  NTESSelectViewController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//
#import "AppDelegate.h"
#import "NTESSelectViewController.h"
#import "NTESWindowContext.h"
#import "NTESLoginManager.h"
#import "NTESP2PVideoChatViewController.h"
#import "NTESP2PAudioChatViewController.h"
#import "NTESMeetingChatViewController.h"
#import "NSView+NTESToast.h"
#import "NTESWindowContext.h"

@interface NTESSelectViewController ()<NSTextFieldDelegate>

@property (nonatomic, assign) CGRect lastReck;
@property (nonatomic, assign) NTESChatMode mode;
@property (nonatomic, strong) NIMNetCallOption *option;

@property (weak) IBOutlet NSPopUpButton *chatModePopUpButton;
@property (weak) IBOutlet NSTextField *peerLabel;
@property (weak) IBOutlet NSTextField *peerTextField;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSTextField *meetingTipsLabel;
@property (weak) IBOutlet NSImageView *logoView;
@property (weak) IBOutlet NSButton *logoutButton;
@property (weak) IBOutlet NSView *peerLine;

@end

@implementation NTESSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
    [self setUpP2PUI];

    self.startButton.enabled = NO;
}

- (void)setUpUI
{
    //注销 button
    NSMutableParagraphStyle *logoutBtnPghStyle = [[NSMutableParagraphStyle alloc] init];
    logoutBtnPghStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *logoutBtnDicAtt = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                             NSParagraphStyleAttributeName : logoutBtnPghStyle,
                             NSFontAttributeName :   [NSFont systemFontOfSize:14]};
    self.logoutButton.attributedTitle = [[NSAttributedString alloc] initWithString:@"注销" attributes:logoutBtnDicAtt];
    
    //发起 button
    NSMutableParagraphStyle *startBtnPghStyle = [[NSMutableParagraphStyle alloc] init];
    startBtnPghStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *startBtnDicAtt = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                             NSParagraphStyleAttributeName : startBtnPghStyle,
                             NSFontAttributeName :   [NSFont systemFontOfSize:16]};
    self.startButton.attributedTitle = [[NSAttributedString alloc] initWithString:@"发起" attributes:startBtnDicAtt];

    
    //logo
    self.logoView.image = [NSImage imageNamed:@"logo"];
    
    //background color
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColorFromRGB(0xFFFFFF).CGColor;
    
    //line color
    self.peerLine.wantsLayer = YES;
    self.peerLine.layer.backgroundColor = NSColorFromRGB(0xD8DCDE).CGColor;
}

- (void)viewWillAppear
{
    [NTESWindowContext sharedInstance].mainWindowController.window.titlebarAppearsTransparent = YES;
    [NTESWindowContext sharedInstance].mainWindowController.window.styleMask = NSWindowStyleMaskTitled| NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable| NSWindowStyleMaskFullSizeContentView;
    
    if (!CGRectEqualToRect(_lastReck, CGRectZero)) {
        [[NTESWindowContext sharedInstance].mainWindowController.window setFrame:_lastReck display:YES];
    }
    
    _lastReck = [NTESWindowContext sharedInstance].mainWindowController.window.frame;
}

- (IBAction)onLogout:(id)sender {
    [[NIMSDK sharedSDK].loginManager logout:^(NSError *error) {
        [[NTESWindowContext sharedInstance] backToLoginWindow];
    }];
}

- (IBAction)join:(id)sender {
    [self start];
}

- (IBAction)onChatModePopUpButtonSelected:(id)sender {
    _mode =(NTESChatMode)_chatModePopUpButton.indexOfSelectedItem;
    switch (_mode) {
        case NTESChatModeAudioP2P:
            [self setUpP2PUI];
            break;
        case NTESChatModeVideoP2P:
            [self setUpP2PUI];
            break;
        case NTESChatModeMeeting:
            [self setUpMeetingUI];
            break;

        default:
            break;
    }
}

- (void)setUpP2PUI
{
    self.peerTextField.hidden = NO;
    self.peerLabel.hidden = NO;
    self.startButton.hidden = NO;
    self.meetingTipsLabel.hidden = YES;
    self.peerLine.hidden = NO;
}

- (void)setUpMeetingUI
{
    self.peerTextField.hidden = YES;
    self.peerLabel.hidden = YES;
    self.startButton.hidden = YES;
    self.peerLine.hidden = YES;
    self.meetingTipsLabel.hidden = NO;
    self.meetingTipsLabel.maximumNumberOfLines = 3;
    [self.meetingTipsLabel setStringValue:@"可在云信即时通讯PC、iOS、Andriod、Web端Demo发起群组音视频通话，MAC端Demo体验多人音视频接听功能。"];
}

- (void)start
{
    if (self.mode == NTESChatModeAudioP2P || self.mode == NTESChatModeVideoP2P) {
        [self startP2P];
    }
}

- (void)startP2P
{
    switch (self.mode) {
        case NTESChatModeAudioP2P:
        {
            NTESP2PAudioChatViewController *vc = [[NTESP2PAudioChatViewController alloc]initWithCallee:_peerTextField.stringValue];
            self.view.window.contentViewController = vc;
        }
            
            break;
        case NTESChatModeVideoP2P:
        {
            NTESP2PVideoChatViewController *vc = [[NTESP2PVideoChatViewController alloc]initWithCallee:_peerTextField.stringValue];
            self.view.window.contentViewController = vc;
        }
            break;

        default:
            break;
    }
}

#pragma mark - NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj
{
    if ([self.peerTextField.stringValue length])
    {
        self.startButton.enabled = YES;
    }
    else{
        self.startButton.enabled = NO;
    }
}

@end
