//
//  NTESGlobalMacro.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/7/11.
//  Copyright © 2018年 netease. All rights reserved.
//

#ifndef NTESGlobalMacro_h
#define NTESGlobalMacro_h

#pragma mark - NSColor宏定义
#define NSColorFromRGBA(rgbValue, alphaValue) [NSColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define NSColorFromRGB(rgbValue) NSColorFromRGBA(rgbValue, 1.0)

#define viewWidth self.view.frame.size.width
#define viewHeight self.view.frame.size.height


#endif /* NTESGlobalMacro_h */
