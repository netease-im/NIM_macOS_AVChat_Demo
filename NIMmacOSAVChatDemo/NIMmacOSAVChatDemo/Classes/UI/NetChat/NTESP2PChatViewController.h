//
//  NTESP2PChatViewController.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class NTESTimerHolder;
@class AVAudioPlayer;

@interface NTESNetCallChatInfo : NSObject

@property(nonatomic,strong) NSString *caller;

@property(nonatomic,strong) NSString *callee;

@property(nonatomic,assign) UInt64 callID;

@property(nonatomic,assign) NIMNetCallMediaType callType;

@property(nonatomic,assign) NSTimeInterval startTime;

@property(nonatomic,assign) BOOL isStart;

@end


@interface NTESP2PChatViewController : NSViewController

@property (nonatomic,strong) NTESNetCallChatInfo *callInfo;

@property (nonatomic,strong) NSString *peerUid;

@property (nonatomic,strong) AVAudioPlayer *player;

- (instancetype)initWithCallee:(NSString *)callee;

- (instancetype)initWithCaller:(NSString *)caller callId:(uint64_t)callID;

- (void)startByCaller;

- (void)startByCallee;

- (void)hangup;

- (void)onNTESTimerFired:(NTESTimerHolder *)holder;

- (void)onControl:(UInt64)callID from:(NSString *)user type:(NIMNetCallControlType)control;
@end

