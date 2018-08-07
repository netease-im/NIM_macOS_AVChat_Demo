//
//  NSView+Toast.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/20.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (NTESToast)

- (void)showToast:(NSString *)message;

- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration;

@end
