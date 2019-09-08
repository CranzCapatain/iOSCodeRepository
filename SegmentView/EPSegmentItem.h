//
//  EPSegmentItem.h
//  AlterDemo
//
//  Created by JinFeng on 2018/11/26.
//  Copyright © 2018年 Alter. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIColor, UIFont, UIImage;
@interface EPSegmentItem : NSObject
@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) UIColor *normalColor;

@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, strong) UIFont *font;

@property (nonatomic, strong) UIFont *seletFont;

@property (nonatomic, strong) UIImage *leftImage;

@property (nonatomic, strong) UIImage *rightImage;

@property (nonatomic, copy) NSDictionary *userInfo;

+ (instancetype)defaultItemWithTitle:(NSString *)title;

@end
