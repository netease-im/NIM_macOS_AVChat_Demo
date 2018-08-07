//
//  NTESBaseChatViewController.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTESMeetingInfo : NSObject

@property (nonatomic,copy) NSString *teamName;

@property (nonatomic,copy) NSString *meetingName;

@property (nonatomic,copy) NSArray *members;

@end

@interface NTESMeetingChatViewController : NSViewController

- (instancetype)initWithMeeting:(NTESMeetingInfo *)info;

@end
