//
//  IAScrollPageController.h
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAScrollPageControllerDelegate.h"
#import "IAScrollPageControllerDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface IAScrollPageController : UIViewController

/**
 底部容器的scrollView，水平滚动的那个
 */
@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, weak) id<IAScrollPageControllerDelegate>delegate;

@property (nonatomic, weak) id<IAScrollPageControllerDataSource>dataSource;

@property (nonatomic, strong, readonly) NSArray *viewControllers;

/**
 界面懒加载，默认YES
 */
@property (nonatomic) BOOL loadLazy;

- (void)reloadData;

- (void)setSelectedAtIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
