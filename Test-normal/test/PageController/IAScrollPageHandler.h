//
//  IAScrollPageHandler.h
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IAScrollPageHandler : NSObject

@property (nonatomic, assign) BOOL loadLazy; // 默认YES

- (instancetype)initWithParentController:(UIViewController *)viewController
                              scrollView:(UIScrollView *)scrollView
                             controllers:(NSArray *)controllers;
@property (nonatomic, strong, readonly) NSArray *controllers;

// 布局，建议放在 【- (void)viewDidLayoutSubviews】
- (void)beginLayoutSubViews;

- (void)scrollToPageAtIndex:(NSUInteger)index animate:(BOOL)animate;

@property (nonatomic, copy) void(^viewLoadFinishCallback)(UIViewController *vc);

@end

NS_ASSUME_NONNULL_END
