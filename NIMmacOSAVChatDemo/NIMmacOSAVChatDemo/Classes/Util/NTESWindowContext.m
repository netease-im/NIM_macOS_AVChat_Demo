//
//  NTESWindowContext.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESWindowContext.h"
#import "NTESLoginManager.h"

@interface NTESWindowContext()

@end

@implementation NTESWindowContext

+ (instancetype)sharedInstance
{
    static NTESWindowContext *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESWindowContext alloc] init];
    });
    return instance;
}

- (void)setupMainWindowController
{
    NTESLoginData *data = [[NTESLoginManager sharedManager] currentNTESLoginData];
    NSString *account = [data account];
    NSString *token   = [data token];
    if ([account length] && [token length])
    {
        [self.mainWindowController.window center];
        [self.mainWindowController.window makeKeyAndOrderFront:nil];
    }
    else
    {
        [self.loginWindowController.window center];
        [self.loginWindowController.window makeKeyAndOrderFront:nil];
    }
}

- (void)onAutoLoginFailed:(NSError *)error
{
    //添加密码出错等引起的自动登录错误处理
    if ([error code] == NIMRemoteErrorCodeInvalidPass ||
        [error code] == NIMRemoteErrorCodeExist)
    {
        [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error) {
            [[NTESLoginManager sharedManager] setCurrentNTESLoginData:nil];
            [self setupMainWindowController];
        }];
    }
}

- (void)onKick:(NIMKickReason)code clientType:(NIMLoginClientType)clientType
{
    NSString *reason = @"你被踢下线";
    switch (code) {
        case NIMKickReasonByClient:
        case NIMKickReasonByClientManually:{
            reason = @"你的帐号被踢出下线，请注意帐号信息安全";
            break;
        }
        case NIMKickReasonByServer:
            reason = @"你被服务器踢下线";
            break;
        default:
            break;
    }
    
    [self backToLoginWindow];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSAlert *alert = [[NSAlert alloc]init];
        [alert addButtonWithTitle:@"确定"];
        [alert setMessageText:reason];
        [alert setAlertStyle:NSAlertStyleInformational];
        [alert beginSheetModalForWindow:self.loginWindowController.window completionHandler:nil];
    });
}

- (void)backToLoginWindow
{
    [[[NIMSDK sharedSDK] loginManager] logout:nil];
    [[NTESLoginManager sharedManager] setCurrentNTESLoginData:nil];
    [self.mainWindowController.window close];
    self.mainWindowController = nil;
    [self setupMainWindowController];
}

- (void)backToMainWindow
{
    if ([self.mainWindowController.window isZoomed]) {
        NSButton *zoomButton = [self.mainWindowController.window standardWindowButton:NSWindowZoomButton];
        [zoomButton performClick:nil];
    }
    self.mainWindowController.window.contentViewController = self.mainWindowController.selectViewCotroller;
}

- (NTESMainWindowController *)mainWindowController
{
    if (!_mainWindowController) {
        _mainWindowController = [[NTESMainWindowController alloc] initWithWindowNibName:@"NTESMainWindowController"];
    }
    return _mainWindowController;
}

- (NTESLaunchWindowController *)loginWindowController
{
    if (!_loginWindowController) {
        _loginWindowController = [[NTESLaunchWindowController alloc] initWithWindowNibName:@"NTESLaunchWindowController"];
    }
    return _loginWindowController;
}


@end
