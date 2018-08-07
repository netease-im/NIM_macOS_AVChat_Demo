//
//  NTESRemoteVideoView.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/4.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESRemoteVideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface NTESRemoteVideoView()

@property (nonatomic, strong) AVSampleBufferDisplayLayer *bufferDisplayer;

@end

@implementation NTESRemoteVideoView
- (AVSampleBufferDisplayLayer *)bufferDisplayer
{
    if (!_bufferDisplayer) {
        _bufferDisplayer = [[AVSampleBufferDisplayLayer alloc] init];
        _bufferDisplayer.videoGravity = AVLayerVideoGravityResizeAspect;
        _bufferDisplayer.frame = self.bounds;
        [self.layer insertSublayer:_bufferDisplayer atIndex:0];
    }
    return _bufferDisplayer;
}

- (void)layout
{
    [super layout];
    _bufferDisplayer.frame = self.bounds;
}

- (void)displaySampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (self.bufferDisplayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
        [self.bufferDisplayer flush];
    }
    else {
        if ([self.bufferDisplayer isReadyForMoreMediaData]) {
            [self.bufferDisplayer enqueueSampleBuffer:sampleBuffer];
        }
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

@end
