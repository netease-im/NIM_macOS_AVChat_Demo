//
//  NTESNotificationCenter.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/6.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTESNotificationCenter : NSObject

+ (instancetype)sharedCenter;

- (void)start;

@end
