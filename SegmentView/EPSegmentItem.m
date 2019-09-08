//
//  EPSegmentItem.m
//  AlterDemo
//
//  Created by JinFeng on 2018/11/26.
//  Copyright © 2018年 Alter. All rights reserved.
//

#import "EPSegmentItem.h"
#import <UIKit/UIFont.h>
#import <UIKit/UIColor.h>

@implementation EPSegmentItem

+ (instancetype)defaultItemWithTitle:(NSString *)title {
    return [[EPSegmentItem alloc] initWithTitle:title];
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if (self) {
        _title = title;
        [self setupInit];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupInit];
    }
    return self;
}

- (void)setupInit {
    _font = [UIFont systemFontOfSize:16];
    _seletFont = [UIFont systemFontOfSize:20];
    _normalColor = [UIColor lightGrayColor];
    _selectedColor = [UIColor blackColor];
}


@end
