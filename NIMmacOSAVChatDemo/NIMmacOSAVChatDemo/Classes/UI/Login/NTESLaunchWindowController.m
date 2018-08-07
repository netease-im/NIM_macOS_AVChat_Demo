//
//  NTESLaunchWindowController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESLaunchWindowController.h"
#import "NTESLoginViewController.h"
@interface NTESLaunchWindowController ()<NSWindowDelegate>

@property (nonatomic,strong) NTESLoginViewController *loginVc;

@end

@implementation NTESLaunchWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.delegate = self;
    self.window.title = @"";
    self.window.contentViewController = self.loginVc;    
    self.window.backgroundColor = NSColorFromRGB(0xFFFFFF);
}

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate:self];
    return YES;
}

- (NTESLoginViewController *)loginVc
{
    if (!_loginVc) {
        _loginVc = [[NTESLoginViewController alloc]init];
    }
    return _loginVc;
}


@end
