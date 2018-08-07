//
//  NTESBaseChatViewController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESMeetingChatViewController.h"
#import "NTESRemoteVideoView.h"
#import "NTESWindowContext.h"
#import "NTESMeetingCollectionViewItem.h"
#import "NSView+NTESToast.h"
#import "NTESTimerHolder.h"

@interface NTESMeetingChatViewController ()<NIMNetCallManagerDelegate,NSCollectionViewDelegate,NSCollectionViewDataSource,NTESTimerHolderDelegate,NSCollectionViewDelegateFlowLayout>
@property (weak) IBOutlet NSTextField *roomNameLabel;
@property (weak) IBOutlet NSTextFieldCell *timeLabel;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSButton *micMuteBtn;
@property (weak) IBOutlet NSButton *cameraBtn;
@property (weak) IBOutlet NSButton *hangupBtn;
@property (weak) IBOutlet NSButton *beautyBtn;

@property (nonatomic,strong) NSView *displayView;
@property (nonatomic,strong) NIMNetCallMeeting *meeting;
@property (nonatomic,strong) NTESMeetingInfo *info;
@property (nonatomic,strong) NTESTimerHolder *timer;
@property (nonatomic,strong) NSMutableArray *remoteVideoViews;
@property (nonatomic,strong) NSMutableArray *userArray;
@property (nonatomic,assign) NSInteger meetingSeconds;
@property (nonatomic,assign) BOOL micMute;
@property (nonatomic,assign) BOOL cameraDisabled;
@property (nonatomic,assign) BOOL beautified;

@end

@implementation NTESMeetingChatViewController

- (instancetype)initWithMeeting:(NTESMeetingInfo *)info;
{
    if (self = [super init]) {
        _info = info;
        _timer = [[NTESTimerHolder alloc]init];
        _remoteVideoViews = [NSMutableArray array];
        _userArray = [NSMutableArray array];
        [_userArray addObject:[NIMSDK sharedSDK].loginManager.currentAccount];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutView) name:NSWindowDidResizeNotification object:nil];

    return self;
}

- (void)layoutView
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NIMAVChatSDK sharedSDK].netCallManager addDelegate:self];
    [self joinMeeting];
    [self initUI];
    _roomNameLabel.stringValue = [NSString stringWithFormat:@"房间名称：%@",_info.teamName];
}

- (void)viewWillAppear
{
    [NTESWindowContext sharedInstance].mainWindowController.window.styleMask = [NTESWindowContext sharedInstance].mainWindowController.window.styleMask | NSWindowStyleMaskResizable;
}

- (void)initUI
{
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.frame = self.collectionView.superview.bounds;
    
    CGFloat height = (self.collectionView.frame.size.height - 4 * 2) / 3;
    CGFloat width = (self.collectionView.frame.size.width - 4 * 2) / 3;
    
    NSCollectionViewFlowLayout *layout = [[NSCollectionViewFlowLayout alloc]init];
    layout.sectionInset = NSEdgeInsetsMake(0, 0, 0, 0);
    layout.itemSize = NSMakeSize(width, height);
    layout.minimumInteritemSpacing = 4;
    layout.minimumLineSpacing = 4;
    
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView registerClass:[NTESMeetingCollectionViewItem class] forItemWithIdentifier:@"collectionViewItem"];
    [self.collectionView setFrameSize: self.collectionView.collectionViewLayout.collectionViewContentSize];
    
    self.collectionView.wantsLayer = YES;
    self.collectionView.layer.backgroundColor = NSColorFromRGBA(0x000000, 0.78).CGColor;

    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = NSColorFromRGBA(0x000000, 0.78).CGColor;
}

- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    CGFloat height = (self.collectionView.superview.frame.size.height  - 4 * 2) / 3;
    CGFloat width = (self.collectionView.superview.frame.size.width - 4 * 2) / 3;

    return NSMakeSize(width, height);
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NTESMeetingCollectionViewItem *item = [collectionView makeItemWithIdentifier:@"collectionViewItem" forIndexPath:indexPath];
    if (indexPath.item == 0) {
        [item refreshWithUserId:[NIMSDK sharedSDK].loginManager.currentAccount];
    }
    return item;
}

- (NSInteger)numberOfSectionsInCollectionView:(NSCollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}

- (void)joinMeeting
{
    __weak typeof(self) wself = self;
    [[NIMAVChatSDK sharedSDK].netCallManager joinMeeting:self.meeting completion:^(NIMNetCallMeeting * _Nonnull meeting, NSError * _Nonnull error) {
        if (error) {
            DDLogError(@"Join meeting %@error: %zd.", meeting.name, error.code);
            [wself.view showToast:@"加入视频聊天失败"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [wself dismiss];
            });
        }
        else
        {
            [wself startTimer];
            DDLogInfo(@"Join meeting %@ success, ext:%@", meeting.name, meeting.ext);
        }
    }];
}

- (void)startTimer
{
    [self.timer startTimer:1 delegate:self repeats:YES];
}

- (void)dealloc
{
    [[NIMAVChatSDK sharedSDK].netCallManager removeDelegate:self];
    NSLog(@"NTESBaseChatViewController dealloc");
}

- (IBAction)micMute:(id)sender {
    _micMute = !_micMute;
    [self.micMuteBtn setImage:[NSImage imageNamed:!_micMute ? @"mic_on_n":@"mic_n"]];
    [self.micMuteBtn setAlternateImage:[NSImage imageNamed:!_micMute ? @"mic_on_p":@"mic_p"]];
    [[NIMAVChatSDK sharedSDK].netCallManager setMute:_micMute];
}

- (IBAction)disabledCamera:(id)sender {
    _cameraDisabled = !_cameraDisabled;
    [self.cameraBtn setImage:[NSImage imageNamed:_cameraDisabled ? @"camera_n":@"camera_on_n"]];
    [self.cameraBtn setAlternateImage:[NSImage imageNamed:!_cameraDisabled ? @"camera_p":@"camera_on_p"]];
    [[NIMAVChatSDK sharedSDK].netCallManager setCameraDisable:_cameraDisabled];
    if (_cameraDisabled) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        NTESMeetingCollectionViewItem *item = (NTESMeetingCollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
        [item removePreView];
    }
}

- (IBAction)beautify:(id)sender {
    _beautified = !_beautified;
    [self.beautyBtn setImage:[NSImage imageNamed:_beautified ? @"beautify_on_n":@"beautify_n"]];
    [self.beautyBtn setAlternateImage:[NSImage imageNamed:_beautified ? @"beautify_on_p":@"beautify_p"]];
    [[NIMAVChatSDK sharedSDK].netCallManager selectBeautifyType:_beautified ? NIMNetCallFilterTypeZiran : NIMNetCallFilterTypeNormal];
}

- (IBAction)dismiss:(id)sender {
    [self dismiss];
}

- (void)dismiss
{
    [[NIMAVChatSDK sharedSDK].netCallManager leaveMeeting:_meeting];
    [[NTESWindowContext sharedInstance] backToMainWindow];
}

- (void)onUserJoined:(NSString *)uid meeting:(NIMNetCallMeeting *)meeting
{
    __weak typeof(self) wself = self;
    
    __block BOOL replaced = NO;
    __block NSInteger index = 0;
    [_userArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj == NULL) {
            [wself.userArray replaceObjectAtIndex:idx withObject:uid];
            replaced = YES;
            index = idx;
        }
        *stop = YES;
    }];
    
    if (!replaced) {
        [_userArray addObject:uid];
        index = _userArray.count - 1;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    NTESMeetingCollectionViewItem *item = (NTESMeetingCollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
    [item refreshWithUserId:uid];
}

- (void)onUserLeft:(NSString *)uid meeting:(NIMNetCallMeeting *)meeting
{
    NSInteger index = [_userArray indexOfObject:uid];
    if (index != NSNotFound) {
        [_userArray replaceObjectAtIndex:index withObject:[NSNull null]];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        NTESMeetingCollectionViewItem *item = (NTESMeetingCollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
        [item refreshWithUserLeft];
    }
}

- (void)onLocalDisplayviewReady:(NSView *)displayView
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    NTESMeetingCollectionViewItem *item = (NTESMeetingCollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
    [item refreshWidthCameraPreview:displayView];
}

- (void)onRemoteVideo:(CMSampleBufferRef)sampleBuffer from:(NSString *)user
{
    NSInteger index = [_userArray indexOfObject:user];
    if (index != NSNotFound) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        NTESMeetingCollectionViewItem *item = (NTESMeetingCollectionViewItem *)[self.collectionView itemAtIndexPath:indexPath];
        [item refreshWithSampleBuffer:sampleBuffer];
    }
}

#pragma mark - Get
- (NIMNetCallMeeting *)meeting
{
    if (!_meeting) {
        _meeting = [[NIMNetCallMeeting alloc] init];
        _meeting.name = _info.meetingName;
        _meeting.actor = YES;
        _meeting.type = NIMNetCallTypeVideo;
        
        NIMNetCallOption *option = [[NIMNetCallOption alloc] init];
        _meeting.option = option;
        
        NIMNetCallVideoCaptureParam *param = [[NIMNetCallVideoCaptureParam alloc]init];
        param.videoProcessorParam = [NIMNetCallVideoProcessorParam new];
        option.videoCaptureParam = param;
    }
    return _meeting;
}

#pragma mark - NTESTimerHolderDelegate
- (void)onNTESTimerFired:(NTESTimerHolder *)holder
{
    self.timeLabel.stringValue = self.timeDuration;
}

- (NSString *)timeDuration
{
    _meetingSeconds ++;
    return [NSString stringWithFormat:@"%02ld:%02ld",_meetingSeconds/60,_meetingSeconds%60];
}

@end

@implementation NTESMeetingInfo
@end

