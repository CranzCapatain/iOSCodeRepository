//
//  KMScrollPageHandler.m
//  KM
//
//  Created by JinFeng on 2018/11/28.
//  Copyright © 2018年 popo.netease.com. All rights reserved.
//

#import "KMScrollPageHandler.h"

@interface KMScrollPageHandler ()<UIScrollViewDelegate>
@property (nonatomic, weak) UIViewController *parentController;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableDictionary *vcIndexDic;
@property (nonatomic, assign) NSUInteger currentIndex;
@end

@implementation KMScrollPageHandler

- (void)dealloc {
    self.scrollView.delegate = nil;
}

- (NSMutableDictionary *)vcIndexDic {
    if (!_vcIndexDic) {
        _vcIndexDic = [NSMutableDictionary dictionary];
    }
    return _vcIndexDic;
}

- (instancetype)initWithParentController:(UIViewController *)viewController scrollView:(UIScrollView *)scrollView controllers:(NSArray *)controllers {
    self = [super init];
    if  (self) {
        _parentController = viewController;
        _scrollView = scrollView;
        _controllers = controllers;
        _scrollView.delegate = self;
        _scrollView.pagingEnabled =YES;
        _scrollView.directionalLockEnabled  = YES;
        _currentIndex = 0;
        UIViewController *firstViewController = controllers.firstObject;
        [viewController addChildViewController:firstViewController];
        [scrollView addSubview:firstViewController.view];
        [self.vcIndexDic setObject:firstViewController forKey:@(0)];
        
        [self beginLayoutSubViews];
    }
    return self;
}

- (void)beginLayoutSubViews {
    CGSize size = self.scrollView.frame.size;
    self.scrollView.contentSize = CGSizeMake(size.width * self.controllers.count, 0);
    for (NSNumber *key in self.vcIndexDic.allKeys) {
        int i = key.intValue;
        UIViewController *viewController = self.controllers[i];
        viewController.view.frame = CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, size.width, size.height);
    }
    [self.scrollView setContentOffset:CGPointMake(self.currentIndex * [UIScreen mainScreen].bounds.size.width, 0)];
}

- (void)scrollToPageAtIndex:(NSUInteger)index animate:(BOOL)animate {
    [UIView animateWithDuration:animate ? 0.3 : 0 animations:^{
        [self.scrollView setContentOffset:CGPointMake([UIScreen mainScreen].bounds.size.width * index, 0)];
    } completion:^(BOOL finished) {
        // 主动滚到这里需要加入未加载的控制器
        [self loadIndex:index];
    }];
}

- (void)setLoadLazy:(BOOL)loadLazy {
    _loadLazy = loadLazy;
    if (!loadLazy) {
        CGSize size = self.scrollView.frame.size;
        for (int i = 0; i < self.controllers.count; ++i) {
            if (i == 0) continue;
            UIViewController *currentViewController = self.controllers[i];
            [self.vcIndexDic setObject:self.controllers[i] forKey:@(i)];
            [self.parentController addChildViewController:currentViewController];
            [self.scrollView addSubview:currentViewController.view];
            currentViewController.view.frame = CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, size.width, size.height);
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.parentController conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.parentController respondsToSelector:@selector(scrollViewDidScroll:)]) {
        if (scrollView.isDragging || scrollView.isDecelerating) {
            [self.parentController performSelector:@selector(scrollViewDidScroll:) withObject:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.parentController conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.parentController respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.parentController performSelector:@selector(scrollViewDidEndDecelerating:) withObject:scrollView];
    }
    NSUInteger index = (NSUInteger)(scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width);
    [self loadIndex:index];
}

- (void)loadIndex:(NSUInteger)index {
    self.currentIndex = index;
    if (self.vcIndexDic[@(index)]) {
        return;
    }
    CGSize size = self.scrollView.frame.size;
    UIViewController *currentViewController = self.controllers[index];
    [self.vcIndexDic setObject:self.controllers[index] forKey:@(index)];
    [self.parentController addChildViewController:currentViewController];
    [self.scrollView addSubview:currentViewController.view];
    currentViewController.view.frame = CGRectMake(index * [UIScreen mainScreen].bounds.size.width, 0, size.width, size.height);
}

@end
