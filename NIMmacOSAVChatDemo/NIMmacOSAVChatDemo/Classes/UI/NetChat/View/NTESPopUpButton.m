//
//  NTESPopUpButton.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/7/17.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESPopUpButton.h"

@implementation NTESPopUpButton

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    //图片
    NSRect rect = NSZeroRect;
    NSImage *arrowImage = [NSImage imageNamed:@"arrow"];
    rect.size = [arrowImage size];
    NSPoint origin = dirtyRect.origin;
    origin.x += dirtyRect.size.width - arrowImage.size.width - 4;
    origin.y += (dirtyRect.size.height - arrowImage.size.height) / 2;
    [arrowImage drawInRect:NSMakeRect(origin.x, origin.y, arrowImage.size.width, arrowImage.size.height) fromRect:rect operation:NSCompositingOperationSourceOver fraction:1.0 respectFlipped:YES hints:nil];
    
    //边框
    NSBezierPath *line = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:5 yRadius:5];
    [line addClip];
    [line setLineWidth:1];
    [NSColorFromRGB(0xCDD0D5) setStroke];
    [line stroke];

    //字体
    NSString *title = [[super selectedItem] title];
    NSDictionary *titleAtt = @{NSForegroundColorAttributeName : NSColorFromRGB(0x656565),
                               NSFontAttributeName : [NSFont systemFontOfSize:12]};
    NSSize titleSize = [title sizeWithAttributes:titleAtt];
    CGFloat titleY = dirtyRect.origin.y + (dirtyRect.size.height - titleSize.height) / 2;
    NSRect titleRect = dirtyRect;
    titleRect.origin = NSMakePoint(10, titleY);
    titleRect.size.height = titleSize.height;
    [title drawInRect:titleRect withAttributes:titleAtt];
}

@end
