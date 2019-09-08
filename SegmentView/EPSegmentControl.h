//
//  EPSegmentControl.h
//  AlterDemo
//
//  Created by JinFeng on 2018/11/26.
//  Copyright © 2018年 Alter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EPSegmentControl : UIControl

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *normalFont;
@property (nonatomic, strong) UIFont *selectFont;
@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) UIImage *rightImage;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;
/// 记录原始的frame
@property (nonatomic, assign) CGRect originRect;

- (CGSize)getTitleSize;
- (CGSize)getSize;
- (CGFloat)getFontChangeScale;

@property (nonatomic, assign) CGFloat colorChangeScale; // 设置渐变颜色的比例

@property (nonatomic, assign) CGFloat fontChangeScale;

@end
