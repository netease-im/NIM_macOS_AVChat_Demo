//
//  AppDelegate.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/5/31.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "AppDelegate.h"
#import <NIMSDK/NIMSDK.h>
#import <NIMAVChat/NIMAVChat.h>
#import "NTESDemoConfig.h"
#import "NTESLoginManager.h"
#import "NTESWindowContext.h"
#import "NTESNotificationCenter.h"
#import "NTESLogManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    NIMSDKOption *option = [[NIMSDKOption alloc] init];
    option.appKey = [[NTESDemoConfig sharedConfig] appKey];
    [[NIMSDK sharedSDK] registerWithOption:option];
    
    [[NTESNotificationCenter sharedCenter] start];
    [[NTESLogManager sharedManager] start];

    [self setupMainWindowController];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)setupMainWindowController
{
    NTESLoginData *data = [[NTESLoginManager sharedManager] currentNTESLoginData];
    NSString *account = [data account];
    NSString *token = [data token];
    if ([account length] && [token length])
    {
        [[[NIMSDK sharedSDK] loginManager] autoLogin:account
                                               token:token];
    }
    
    [[NTESWindowContext sharedInstance] setupMainWindowController];
}

@end
