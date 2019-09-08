//
//  IAScrollPageControllerDataSource.h
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IAScrollPageController;
@protocol IAScrollPageSubControllerProtocol;

@protocol IAScrollPageControllerDataSource <NSObject>

@required
- (NSArray <UIViewController<IAScrollPageSubControllerProtocol> *> *)viewControllersForPage:(IAScrollPageController *)pageController;

@optional
- (UIView *)headerViewForPage:(IAScrollPageController *)pageController;

/**
 正常状态到滚动多少悬停

 @return 需要滚动的距离
 */
- (CGFloat)scrollHoverInHeaderViewOffsetYForPage:(IAScrollPageController *)pageController;

/**
 默认选中的位置
 
 @param pageController *
 @return 默认下标
 */
- (NSUInteger)selectedAtIndexForPage:(IAScrollPageController *)pageController;

@end

NS_ASSUME_NONNULL_END
