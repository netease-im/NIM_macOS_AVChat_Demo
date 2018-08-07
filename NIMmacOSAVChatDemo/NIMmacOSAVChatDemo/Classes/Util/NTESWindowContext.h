//
//  NTESWindowContext.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NTESMainWindowController.h"
#import "NTESLaunchWindowController.h"

@interface NTESWindowContext : NSObject

@property (nonatomic,strong) NTESMainWindowController *mainWindowController;
@property (nonatomic,strong) NTESLaunchWindowController *loginWindowController;

+ (instancetype)sharedInstance;

- (void)setupMainWindowController;

- (void)backToLoginWindow;

- (void)backToMainWindow;

@end
