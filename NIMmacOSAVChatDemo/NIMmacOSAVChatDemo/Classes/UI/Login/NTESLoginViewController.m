//
//  NTESLoginViewController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/5/31.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESLoginViewController.h"
#import "NTESMainWindowController.h"
#import "NSString+NTES.h"
#import "NTESLoginManager.h"
#import "NSView+NTESToast.h"
#import "NTESWindowContext.h"

@interface NTESLoginViewController ()<NSTextFieldDelegate>

@property (weak) IBOutlet NSTextField *usernameTextField;
@property (weak) IBOutlet NSSecureTextField *passwordTextField;
@property (nonatomic, strong)NTESMainWindowController *selectWindow;
@property (weak) IBOutlet NSButton *loginBtn;
@property (weak) IBOutlet NSView *usernameLine;
@property (weak) IBOutlet NSView *passwordLine;

@end

@implementation NTESLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpUI];
}

- (void)viewWillAppear
{
    _usernameTextField.stringValue = @"";
    _passwordTextField.stringValue = @"";
    [_usernameTextField becomeFirstResponder];
    _loginBtn.enabled = NO;
}

- (void)setUpUI
{
    NSMutableParagraphStyle *pghStyle = [[NSMutableParagraphStyle alloc] init];
    pghStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *dicAtt = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                             NSParagraphStyleAttributeName : pghStyle,
                             NSFontAttributeName :   [NSFont systemFontOfSize:16]};
    self.loginBtn.attributedTitle = [[NSAttributedString alloc] initWithString:@"登录" attributes:dicAtt];
    self.loginBtn.attributedAlternateTitle = [[NSAttributedString alloc] initWithString:@"登录" attributes:dicAtt];

    self.usernameLine.wantsLayer = YES;
    self.usernameLine.layer.backgroundColor = NSColorFromRGB(0xD8DCDE).CGColor;
    
    self.passwordLine.wantsLayer = YES;
    self.passwordLine.layer.backgroundColor = NSColorFromRGB(0xD8DCDE).CGColor;
}

- (IBAction)onTouchLogin:(id)sender {
    [self doLogin];
}

- (void)doLogin
{
    NSString *username = [_usernameTextField.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = _passwordTextField.stringValue;
    
    NSString *loginAccount = username;
    NSString *loginToken   = [password tokenByPassword];

    [[[NIMSDK sharedSDK] loginManager] login:loginAccount
                                       token:loginToken
                                  completion:^(NSError *error) {
                                      if (error == nil)
                                      {
                                          DDLogInfo(@"login success");
                                          NTESLoginData *sdkData = [[NTESLoginData alloc] init];
                                          sdkData.account   = loginAccount;
                                          sdkData.token     = loginToken;
                                          [[NTESLoginManager sharedManager] setCurrentNTESLoginData:sdkData];
                                          [self showSelectWindow];
                                      }
                                      else
                                      {
                                          DDLogInfo(@"login failed");
                                          if (error.code == NIMRemoteErrorCodeInvalidPass)
                                          {
                                              [self.view showToast:@"账号密码错误"];
                                          }
                                          else
                                          {
                                              [self.view showToast:[NSString stringWithFormat:@"登录失败 code: %zd",error.code]];
                                          }
                                      }
                                  }];
}

//显示选择窗口
- (void)showSelectWindow
{
    //关闭本窗口
    [self.view.window orderOut:nil];
    
    [[NTESWindowContext sharedInstance] setupMainWindowController];
}

#pragma mark - NSTextFieldDelegate
- (void)controlTextDidChange:(NSNotification *)obj
{
    if ([self.usernameTextField.stringValue length] && [self.passwordTextField.stringValue length])
    {
        self.loginBtn.enabled = YES;
    }
    else
    {
        self.loginBtn.enabled = NO;
    }
}

@end
