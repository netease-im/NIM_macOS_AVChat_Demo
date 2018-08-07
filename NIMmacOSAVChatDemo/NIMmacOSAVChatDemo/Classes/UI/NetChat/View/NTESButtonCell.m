//
//  NTESButton.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/7/17.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESButtonCell.h"

@interface NTESButtonCell()
@end

@implementation NTESButtonCell

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    if (![self isEnabled]) {
        return [super drawTitle:[self attributedTitle] withFrame:frame inView:controlView];
    }
    
    return [super drawTitle:title withFrame:frame inView:controlView];
}

@end

