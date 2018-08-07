//
//  NSView+Toast.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/20.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NSView+NTESToast.h"

static const NSTimeInterval NTESToastDefaultDuration  = 2.0;

@implementation NSView (NTESToast)
- (void)showToast:(NSString *)message {
    [self showToast:message duration:NTESToastDefaultDuration];
}

- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration{
    NSView *toast = [self viewForMessage:message];
    [self show:toast duration:duration];
}

- (void)show:(NSView *)view duration:(NSTimeInterval)duration
{
    [self addSubview:view];
    [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(onTimerFired:) userInfo:view repeats:NO];
}

- (void)onTimerFired:(NSTimer *)timer
{
    NSView *view = (NSView *)timer.userInfo;
    [view removeFromSuperview];
}

- (NSView *)viewForMessage:(NSString *)message {
    NSView *toastView = [[NSView alloc] init];
    toastView.wantsLayer = YES;
    toastView.layer.backgroundColor = [[NSColor blackColor] colorWithAlphaComponent:0.7].CGColor;
    //avoid blurry text
    toastView.canDrawSubviewsIntoLayer = true;

    //message label
    NSTextField *messageLabel = [NSTextField labelWithString:message];
    messageLabel.textColor = [NSColor whiteColor];
    messageLabel.backgroundColor = [NSColor clearColor];
    messageLabel.alignment = NSTextAlignmentCenter;

    CGFloat labelWidth = messageLabel.frame.size.width;
    CGFloat labelHeight = messageLabel.frame.size.height;
    
    CGFloat widthPadding = 10;
    CGFloat heightPadding = 10;
    
    CGFloat toastViewWidth = labelWidth + widthPadding;
    CGFloat toastViewHeight = labelHeight + heightPadding;
    
    //toastView frame
    toastView.frame = NSMakeRect(self.frame.size.width / 2 - toastViewWidth / 2 , self.frame.size.height / 2 - toastViewHeight / 2, labelWidth + widthPadding, labelHeight + heightPadding);
    toastView.layer.cornerRadius = labelHeight / 2;
    
    //message label frame
    messageLabel.frame = NSMakeRect(widthPadding / 2, heightPadding / 2, labelWidth, labelHeight);
    
    [toastView addSubview:messageLabel];
    
    return toastView;
}

@end
