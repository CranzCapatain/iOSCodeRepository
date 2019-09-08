//
//  IAScrollPageControllerDelegate.h
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class IAScrollPageController;

@protocol IAScrollPageControllerDelegate <NSObject>

@optional
- (void)pageController:(IAScrollPageController *)controller scrollViewDidLoad:(UIScrollView *)scrollView;

- (void)pageController:(IAScrollPageController *)controller subVCDidLoad:(UIViewController *)viewController;

/**
 垂直滚动的回调

 @param controller *
 @param scrollView 当前在滚动的那个scrollView
 @param offsetY 这个是修正之后的偏移
 */
- (void)pageController:(IAScrollPageController *)controller vscrollDidScroll:(UIScrollView *)scrollView offsetY:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
