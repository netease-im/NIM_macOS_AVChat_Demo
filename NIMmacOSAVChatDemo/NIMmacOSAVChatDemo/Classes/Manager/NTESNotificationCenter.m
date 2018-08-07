//
//  NTESNotificationCenter.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#define NTESNotifyID        @"id"
#define NTESTeamMeetingName  @"room"
#define NTESTeamMeetingMembers  @"members"
#define NTESTeamMeetingTeamName @"teamName"
#define NTESTeamMeetingCall (3)


#import "NTESNotificationCenter.h"
#import "NTESChatNotificationController.h"
#import "NTESWindowContext.h"
#import "NTESP2PChatViewController.h"
#import "NTESMeetingChatViewController.h"
#import "NSDictionary+NTESJson.h"

@interface NTESNotificationCenter ()<NIMNetCallManagerDelegate,NIMSystemNotificationManagerDelegate>
@end

@implementation NTESNotificationCenter

+ (instancetype)sharedCenter
{
    static NTESNotificationCenter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NTESNotificationCenter alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
        [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    }
    return self;
}

- (void)start
{
    DDLogInfo(@"Notification Center Setup");
}

- (BOOL)shouldResponseBusy
{
    NSViewController *currentController = [NTESWindowContext sharedInstance].mainWindowController.window.contentViewController;
    return [currentController isKindOfClass:[NTESChatNotificationController class]] || [currentController isKindOfClass:[NTESP2PChatViewController class]] || [currentController isKindOfClass:[NTESMeetingChatViewController class]] ;
}

- (void)onReceive:(UInt64)callID from:(NSString *)caller type:(NIMNetCallMediaType)type message:(NSString *)extendMessage
{
    if ([self shouldResponseBusy]){
        //告诉对方占线了
        [[NIMAVChatSDK sharedSDK].netCallManager control:callID type:NIMNetCallControlTypeBusyLine];
        return;
    }
    
    NSViewController *vc;
    switch (type) {
        case NIMNetCallTypeVideo:{
            vc = [[NTESChatNotificationController alloc] initWithChatMode:NTESChatModeVideoP2P caller:caller callID:callID];
            
        }
            break;
        case NIMNetCallTypeAudio:{
            vc = [[NTESChatNotificationController alloc] initWithChatMode:NTESChatModeAudioP2P caller:caller callID:callID];
        }
            break;
        default:
            break;
    }
    
    [NTESWindowContext sharedInstance].mainWindowController.window.contentViewController = vc;
}

#pragma mark - NIMSystemNotificationManagerDelegate
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    NSString *content = notification.content;
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    if (data) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:nil];
        switch ([dict jsonInteger:NTESNotifyID]) {
            case NTESTeamMeetingCall:{
                if (![self shouldResponseBusy]) {
                    //caller的信息暂时没有发送过来
                    NTESMeetingInfo *meetingInfo = [[NTESMeetingInfo alloc] init];
                    meetingInfo.meetingName = [dict jsonString:NTESTeamMeetingName];
                    meetingInfo.teamName = [dict jsonString:NTESTeamMeetingTeamName];
                    meetingInfo.members = [dict jsonArray:NTESTeamMeetingMembers];

                    NSString *caller = meetingInfo.members.firstObject;
                    NTESChatNotificationController *vc = [[NTESChatNotificationController alloc] initWithMeetingInfo:meetingInfo caller:caller];
                    [NTESWindowContext sharedInstance].mainWindowController.window.contentViewController = vc;
                }
            }
                break;
            default:
                break;
        }
    }
}

@end
