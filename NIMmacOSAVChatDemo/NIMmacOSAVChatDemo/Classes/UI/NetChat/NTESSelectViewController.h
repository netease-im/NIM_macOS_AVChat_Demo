//
//  NTESSelectViewController.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, NTESChatMode) {
    NTESChatModeAudioP2P = 0,
    NTESChatModeVideoP2P = 1,
    NTESChatModeMeeting  = 2,
};

@interface NTESSelectViewController : NSViewController

@end
