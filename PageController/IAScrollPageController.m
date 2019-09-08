//
//  IAScrollPageController.m
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import "IAScrollPageController.h"
#import "IAScrollPageHandler.h"
#import "IAScrollPageSubControllerProtocol.h"
#import "IAScrollOffsetHandler.h"
#import <objc/runtime.h>

static char *kPageTagKey;

@interface IAScrollPageController ()<IAScrollOffsetDelegate>
{
    CGFloat _currentScrollOffsetY;
    IAScrollPageHandler *_scrollHandler;
    IAScrollOffsetHandler *_offsetHandler;
    UIView *_header;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, assign) CGFloat currentFixOffsetY;
@end

@implementation IAScrollPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupContainer];
    [self _setupConfig];
}

- (void)_setupContainer {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_offsetHandler beginListern];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_offsetHandler stopListern];
}

- (void)_setupConfig {
    self.loadLazy = YES;
    extern NSString *IAListFirstReloadNotification;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReloadData:) name:IAListFirstReloadNotification object:nil];
}

- (void)_setupUI {
    // vcs
    [self _setupVCs];
    // header
    [self _setupHeader];
}

- (void)_setupVCs {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewControllersForPage:)]) {
        NSArray *vcs = [self.dataSource viewControllersForPage:self];
        if (self.viewControllers.count > 0) {
            [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromParentViewController];
                [obj.view removeFromSuperview];
            }];
        }
        self.viewControllers = nil;
        self.viewControllers = vcs;
        NSUInteger index = 0;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(selectedAtIndexForPage:)]) {
            index = [self.dataSource selectedAtIndexForPage:self];
        }
        _scrollHandler = [[IAScrollPageHandler alloc] initWithParentController:self scrollView:self.scrollView controllers:vcs atIndex:index];
        _scrollHandler.loadLazy = self.loadLazy;
        __weak typeof(self) weakSelf = self;
        _scrollHandler.viewLoadFinishCallback = ^(UIViewController *vc) {
            [weakSelf _adjustToHeaderWithSubVC:vc];
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(pageController:subVCDidLoad:)]) {
                [weakSelf.delegate pageController:weakSelf subVCDidLoad:vc];
            }
        };
    }
}

- (void)_adjustToHeaderWithSubVC:(UIViewController *)vc {
    if ([vc respondsToSelector:@selector(pageSubScrollView)]) {
        UIScrollView *sc = [(id<IAScrollPageSubControllerProtocol>)vc pageSubScrollView];
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageController:scrollViewDidLoad:)]) {
            [self.delegate pageController:self scrollViewDidLoad:sc];
        }
        objc_setAssociatedObject(sc, "IAFirstLoad", @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
        objc_setAssociatedObject(sc, &kPageTagKey, self, OBJC_ASSOCIATION_ASSIGN);
//        DDLogDebug(@"=sc insets:%@|offset:%@|contentSize:%@",NSStringFromUIEdgeInsets(sc.contentInset),NSStringFromCGPoint(sc.contentOffset),NSStringFromCGSize(sc.contentSize));
        
        if (@available(iOS 11.0, *)){
            [sc setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        } else {
            vc.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        BOOL is_x = (([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.height == 896) ? YES : NO);
        CGFloat tabbarHeight = is_x ? 83 : 49;
        BOOL hasTabBar = (self.tabBarController && !self.tabBarController.tabBar.hidden);
        
        [sc setContentInset:UIEdgeInsetsMake(sc.contentInset.top + _header.frame.size.height, sc.contentInset.left, sc.contentInset.bottom + (hasTabBar ? tabbarHeight : 0), sc.contentInset.right)];
        [sc setContentOffset:CGPointMake(0, -sc.contentInset.top)];
        
        
        if (!objc_getAssociatedObject(sc, "isIAScroll")) {
            // fix
            [sc setContentInset:UIEdgeInsetsMake(sc.contentInset.top - _offsetHandler.currentOffsetFix, sc.contentInset.left, sc.contentInset.bottom, sc.contentInset.right)];
        } else {
            [_offsetHandler addListernScrollView:sc];
        }
        
        // 打个标记
        objc_setAssociatedObject(sc, "isIAScroll", @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)notificationReloadData:(NSNotification *)noti {
    UIScrollView *sc = noti.object;
    id obj = objc_getAssociatedObject(sc, &kPageTagKey);
    if (sc && [sc isKindOfClass:[UIScrollView class]] && (obj == self)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [sc setContentInset:UIEdgeInsetsMake(sc.contentInset.top + _offsetHandler.currentOffsetFix, sc.contentInset.left, sc.contentInset.bottom, sc.contentInset.right)];
            [sc setContentOffset:CGPointMake(0, _offsetHandler.currentOffsetFix - sc.contentInset.top)];
            [_offsetHandler addListernScrollView:sc];
        });
    }
}

#pragma mark - Header

- (void)_setupHeader {
    UIView *header = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(headerViewForPage:)]) {
        header = [self.dataSource headerViewForPage:self];
    }
    if (!header) return;
    if (_header) {
        [_header removeFromSuperview];
        _header = nil;
    }
    _header = header;
    [self.view addSubview:_header];
    
    _offsetHandler = [[IAScrollOffsetHandler alloc] initWithHeaderView:header];
    _offsetHandler.delegate = self;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(scrollHoverInHeaderViewOffsetYForPage:)]) {
        _offsetHandler.scrollStopHover = [self.dataSource scrollHoverInHeaderViewOffsetYForPage:self];
    }
    
    CGRect headeFrame = _header.frame;
    header.frame = CGRectMake(headeFrame.origin.x, headeFrame.origin.y, self.view.bounds.size.width, headeFrame.size.height);
}

- (void)viewDidLayoutSubviews {
    self.scrollView.frame = self.view.bounds;
    CGRect headeFrame = _header.frame;
    _header.frame = CGRectMake(headeFrame.origin.x, headeFrame.origin.y, self.view.bounds.size.width, headeFrame.size.height);
    // update vcs layout
    [_scrollHandler beginLayoutSubViews];
}

#pragma mark - Public
// create UI again
- (void)reloadData {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _setupUI];
    });
}

- (void)setSelectedAtIndex:(NSUInteger)index {
    [_scrollHandler scrollToPageAtIndex:index animate:YES];
}

#pragma mark - IAScrollOffsetDelegate

- (void)offsetHandler:(IAScrollOffsetHandler *)handler scrollDidScroll:(UIScrollView *)scrollView fixOffsetY:(CGFloat)fixOffsetY {
    self.currentFixOffsetY = fixOffsetY;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageController:vscrollDidScroll:offsetY:)]) {
        [self.delegate pageController:self vscrollDidScroll:scrollView offsetY:fixOffsetY];
    }
}

@end
