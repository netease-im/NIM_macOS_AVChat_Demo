//
//  NTESMainWindowController.m
//  NIMmacOSAVChatDemo
//
//  Created by Simon Blue on 2018/6/1.
//  Copyright © 2018年 netease. All rights reserved.
//

#import "NTESMainWindowController.h"
@interface NTESMainWindowController ()<NSWindowDelegate>

@end

@implementation NTESMainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.delegate = self;
    self.window.contentViewController = self.selectViewCotroller;
}

- (NTESSelectViewController *)selectViewCotroller
{
    if (!_selectViewCotroller) {
        _selectViewCotroller = [[NTESSelectViewController alloc]init];
    }
    return _selectViewCotroller;
}

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate:self];
    return YES;
}

@end
