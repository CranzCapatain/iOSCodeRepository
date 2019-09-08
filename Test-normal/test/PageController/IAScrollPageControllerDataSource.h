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

- (CGRect)rectOfHeaderViewForPage:(IAScrollPageController *)pageController;

/**
 头部滚动到多少是悬停

 @return y轴的偏移
 */
- (CGFloat)scrollHoverInHeaderViewOffsetYForPage:(IAScrollPageController *)pageController;

@end

NS_ASSUME_NONNULL_END
