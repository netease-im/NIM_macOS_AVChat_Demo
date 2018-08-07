//
//  NTESMeetingCollectionViewItem.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/8.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESMeetingCollectionViewItem.h"
#import "NTESRemoteVideoView.h"

@interface NTESMeetingCollectionViewItem ()
@property (nonatomic,strong) NSTextField *userLabel;
@property (nonatomic,strong) NSView *localView;
@property (nonatomic,strong) NSView *displayView;
@property (nonatomic,strong) NSImageView *offlineImageView;
@property (nonatomic,strong) NTESRemoteVideoView *remoteView;

@end

@implementation NTESMeetingCollectionViewItem

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.remoteView];
    [self.view addSubview:self.localView];
    [self.view addSubview:self.offlineImageView];
    [self.view addSubview:self.userLabel];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColorFromRGB(0x424242).CGColor;
}

- (void)refreshWithUserId:(NSString *)uid
{
    self.userLabel.stringValue = uid;
}

- (void)refreshWithUserLeft
{
    self.offlineImageView.hidden = NO;
    self.userLabel.stringValue = @"已挂断";
}

- (void)refreshWithSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    self.remoteView.hidden = NO;
    self.localView.hidden = YES;
    self.offlineImageView.hidden = YES;
    [self.remoteView displaySampleBuffer:sampleBuffer];
}

- (void)refreshWidthCameraPreview:(NSView *)preview
{
    _displayView = preview;
    _displayView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    self.localView.hidden = NO;
    self.remoteView.hidden = YES;
    self.offlineImageView.hidden = YES;
    _displayView.frame = self.localView.bounds;
    [self.localView addSubview:_displayView];
}

- (void)removePreView
{
    [self.displayView removeFromSuperview];
}

- (NSView *)localView
{
    if (!_localView) {
        _localView  = [[NSView alloc]initWithFrame:self.view.bounds];
        _localView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    }
    return _localView;
}

- (NTESRemoteVideoView *)remoteView
{
    if (!_remoteView) {
        _remoteView  = [[NTESRemoteVideoView alloc]initWithFrame:self.view.bounds];
        _remoteView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    }
    return _remoteView;
}

- (NSImageView *)offlineImageView
{
    if (!_offlineImageView) {
        _offlineImageView = [[NSImageView  alloc]initWithFrame:self.view.bounds];
        _offlineImageView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
        _offlineImageView.imageScaling = NSImageScaleAxesIndependently;
        _offlineImageView.image = [NSImage imageNamed:@"user_offline"];
    }
    return _offlineImageView;
}

- (NSTextField *)userLabel
{
    if (!_userLabel) {
        NSString *title = @"";
        _userLabel = [NSTextField labelWithString:title];
        _userLabel.alignment = NSTextAlignmentCenter;
        [_userLabel sizeToFit];
        [_userLabel setTextColor:[NSColor whiteColor]];
        _userLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:-10]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_userLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    }
    return _userLabel;
}

@end
