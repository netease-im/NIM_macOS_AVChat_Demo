//
//  NTESChatNotificationController.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NTESSelectViewController.h"

@class NTESMeetingInfo;

@interface NTESChatNotificationController : NSViewController

- (instancetype)initWithChatMode:(NTESChatMode)chatMode caller:(NSString *)caller callID:(UInt64)callID;

- (instancetype)initWithMeetingInfo:(NTESMeetingInfo *)info caller:(NSString *)caller;



@end
