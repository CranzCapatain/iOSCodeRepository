//
//  EPSegmentView.h
//  AlterDemo
//
//  Created by JinFeng on 2018/11/26.
//  Copyright © 2018年 Alter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EPSegmentItem.h"

@class EPSegmentView;
@protocol EPSegmentViewDelegate<NSObject>

@optional
/**
 指示杆的宽度是否自适应选中标题的长度，默认NO
 
 @return bool
 */
- (BOOL)isAdjustIndicateViewWidthToTitle;

/**
 返回默认指示杆的长度，如果【adjustIndicateViewWidthToTitle】方法返回NO；当【adjustIndicateViewWidthToTitle】为YES时设置无效
 
 @return 指示杆的宽度
 */
- (CGFloat)indicateViewWidthIfNotAdjustToTitle;

/**
 item之间的最小间隙，如果未设置，则默认为20
 
 @return real space of items
 */
- (CGFloat)minSpaceOfItems;

/**x
 整个内容视图的内边距，默认 {0,x,0,x}。x会根据你添加的items宽度和space来计算，不固定，最小是16。
 一旦设置了那边距，就会按照内边距来强制布局，此时的内边距就是固定的
 @return *
 */
- (UIEdgeInsets)contentEdgeInsets;

@required
- (void)segmentView:(EPSegmentView *)segmentView didSelectedWithItem:(EPSegmentItem *)item atIndex:(NSUInteger)index;

@end

typedef NS_ENUM(unsigned, EPSegmentIndicateLocationStyle) {
    /// 滑杆在文字下方固定位置
    EPSegmentIndicateLocationStyleDefault,
    /// 滑杆贴着底部 默认
    EPSegmentIndicateLocationStyleBottom,
};

typedef NS_ENUM(unsigned, EPSegmentIndicateAnimationMode) {
    /// 追踪模式 默认
    EPSegmentIndicateAnimationTrackMode,
};

@interface EPSegmentView : UIView

@property (nonatomic, weak) id<EPSegmentViewDelegate> delegate;
@property (nonatomic, assign, readonly) NSUInteger selectedIndex;
@property (nonatomic, assign) EPSegmentIndicateAnimationMode animationMode;
/**
 指示杆
 */
@property (nonatomic, strong, readonly) UIImageView *indicateView;
@property (nonatomic, assign) EPSegmentIndicateLocationStyle indicateLocationStyle;
/**
 是否显示在导航栏上，默认NO
 添加在导航栏上后会忽略内边距
 */
@property (nonatomic, assign) BOOL addToNavigationItemView;
/**
 是否显示底下细线，默认NO
 */
@property (nonatomic, assign) BOOL showBottomSingleLine;
@property (nonatomic, assign) BOOL bounces;
/**
 颜色渐变
 */
@property (nonatomic, assign) BOOL openColorGraduallyChange;
/**
 字体渐变
 */
@property (nonatomic, assign) BOOL openFontGraduallyChange;

- (void)displayWithItems:(NSArray <EPSegmentItem *>*)items;

/**
 设置选中位置，默认是选中index=0
 
 @param index 默认index
 */
- (void)setSelectedAtIndex:(NSUInteger)index
                   animate:(BOOL)animate;

/**
 设置指示杆的相对移动位置
 
 @param offsetX 滑动距离，例如屏幕的滑动距离
 @param relativeWidth 相对宽度，例如屏幕的宽度
 */
- (void)scrollIndicateViewWithOffset:(CGFloat)offsetX
                       relativeWidth:(CGFloat)relativeWidth;

/**
 在动态调用‘displayWithItems’时，需要调用reload来显示最新的数据
 */
- (void)reloadData;

@end
