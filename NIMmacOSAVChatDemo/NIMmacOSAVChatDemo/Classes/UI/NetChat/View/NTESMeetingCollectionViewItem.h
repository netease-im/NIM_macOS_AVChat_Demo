//
//  NTESMeetingCollectionViewItem.h
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/8.
//  Copyright © 2018年 netease. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NTESMeetingCollectionViewItem : NSCollectionViewItem

- (void)refreshWithUserLeft;

- (void)refreshWithUserId:(NSString *)uid;

- (void)refreshWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

- (void)refreshWidthCameraPreview:(NSView *)preview;

- (void)removePreView;

@end
