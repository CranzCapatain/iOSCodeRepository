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

@interface IAScrollPageController ()
{
    CGFloat _currentScrollOffsetY;
    IAScrollPageHandler *_scrollHandler;
    IAScrollOffsetHandler *_offsetHandler;
    UIView *_header;
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *viewControllers;
@end

@implementation IAScrollPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setupConfig];
}

- (void)_setupConfig {
    self.loadLazy = YES;
}

- (void)_setupUI {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    // vcs
    [self _setupVCs];
    // header
    [self _setupHeader];
}

- (void)_setupVCs {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(viewControllersForPage:)]) {
        NSArray *vcs = [self.dataSource viewControllersForPage:self];
        self.viewControllers = vcs;
        _scrollHandler = [[IAScrollPageHandler alloc] initWithParentController:self scrollView:self.scrollView controllers:vcs];
        _scrollHandler.loadLazy = self.loadLazy;
        __weak typeof(self) weakSelf = self;
        _scrollHandler.viewLoadFinishCallback = ^(UIViewController *vc) {
            [weakSelf _adjustToHeaderWithSubVC:vc];
        };
    }
}

- (void)_adjustToHeaderWithSubVC:(UIViewController *)vc {
    if ([vc respondsToSelector:@selector(pageSubScrollView)]) {
        UIScrollView *sc = [(id<IAScrollPageSubControllerProtocol>)vc pageSubScrollView];
        [sc setContentInset:UIEdgeInsetsMake(sc.contentInset.top + _header.frame.size.height, sc.contentInset.left, sc.contentInset.bottom, sc.contentInset.right)];
        [sc setContentOffset:CGPointMake(0, -sc.contentInset.top)];
        // 添加监听
        [_offsetHandler addListernScrollView:sc];
    }
}

#pragma mark - Header

- (void)_setupHeader {
    UIView *header = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(headerViewForPage:)]) {
        header = [self.dataSource headerViewForPage:self];
    }
    if (!header) return;
    _header = header;
    [self.view addSubview:_header];
    
    _offsetHandler = [[IAScrollOffsetHandler alloc] initWithHeaderView:header];
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(scrollHoverInHeaderViewOffsetYForPage:)]) {
        _offsetHandler.scrollStopHover = [self.dataSource scrollHoverInHeaderViewOffsetYForPage:self];
    }
    
    CGRect headeFrame = _header.frame;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(rectOfHeaderViewForPage:)]) {
        headeFrame = [self.dataSource rectOfHeaderViewForPage:self];
    }
    header.frame = CGRectMake(headeFrame.origin.x, headeFrame.origin.y, self.view.bounds.size.width, headeFrame.size.height);
}

- (void)viewDidLayoutSubviews {
    // update scrollview layout
    self.scrollView.frame = self.view.bounds;
    // update header layout
    CGRect headeFrame = _header.frame;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(rectOfHeaderViewForPage:)]) {
        headeFrame = [self.dataSource rectOfHeaderViewForPage:self];
    }
    _header.frame = CGRectMake(headeFrame.origin.x, headeFrame.origin.y, self.view.bounds.size.width, headeFrame.size.height);
    // update vcs layout
    [_scrollHandler beginLayoutSubViews];
}

- (void)reloadData {
    [self _setupUI];
}

@end
