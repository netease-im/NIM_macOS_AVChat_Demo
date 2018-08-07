//
//  NTESRemoteVideoView.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/4.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreMedia/CoreMedia.h>

@interface NTESRemoteVideoView : NSView

@property(nonatomic,strong) NSString *identity;

- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
