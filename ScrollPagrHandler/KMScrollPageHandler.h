//
//  KMScrollPageHandler.h
//  KM
//
//  Created by JinFeng on 2018/11/28.
//  Copyright © 2018年 popo.netease.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KMScrollPageHandler : NSObject
@property (nonatomic, assign) BOOL loadLazy; // 默认YES

- (instancetype)initWithParentController:(UIViewController *)viewController
                              scrollView:(UIScrollView *)scrollView
                             controllers:(NSArray *)controllers;
@property (nonatomic, strong, readonly) NSArray *controllers;

// 布局，建议放在 【- (void)viewDidLayoutSubviews】
- (void)beginLayoutSubViews;

- (void)scrollToPageAtIndex:(NSUInteger)index animate:(BOOL)animate;

@end

NS_ASSUME_NONNULL_END
