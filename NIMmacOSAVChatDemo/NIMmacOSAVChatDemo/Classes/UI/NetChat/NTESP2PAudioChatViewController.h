//
//  NTESP2PAudioChatViewController.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NTESP2PChatViewController.h"

@interface NTESP2PAudioChatViewController : NTESP2PChatViewController

- (instancetype)initWithCallInfo:(NTESNetCallChatInfo *)callInfo;

@end
