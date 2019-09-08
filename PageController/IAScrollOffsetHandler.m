//
//  IAScrollOffsetHandler.m
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import "IAScrollOffsetHandler.h"
#import <objc/runtime.h>

static char *kScrollIgnoreKey;

@interface IAScrollOffsetHandler ()
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, strong) NSMutableArray *scs;
@property (nonatomic, assign) CGRect originHeaderFrame;
@property (nonatomic, assign) BOOL fixOffset;
@property (nonatomic, assign) CGFloat currentOffsetFix;
@end

@implementation IAScrollOffsetHandler

- (void)dealloc {
    for (UIScrollView *sc in self.scs) {
        [sc removeObserver:self forKeyPath:@"contentOffset"];
        [self.scs removeObject:sc];
    }
}

- (instancetype)initWithHeaderView:(UIView *)headerView {
    self = [super init];
    if (self) {
        _headerView = headerView;
        _originHeaderFrame = headerView.frame;
        _scrollStopHover = _originHeaderFrame.size.height;
//        DDLogDebug(@"=sc remark origin header frame:%@",NSStringFromCGRect(_originHeaderFrame));
        _scs = [NSMutableArray array];
    }
    return self;
}

- (void)addListernScrollView:(UIScrollView *)sc {
    if (!sc) {
        return;
    }
//    DDLogDebug(@"=sc init sc offset:%@|insets:%@",NSStringFromCGPoint(sc.contentOffset),NSStringFromUIEdgeInsets(sc.contentInset));
    [self.scs addObject:sc];
    [sc addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)removeListernScrollView:(UIScrollView *)sc {
    if (!sc) {
        return;
    }
    if ([self.scs containsObject:sc]) {
        [sc removeObserver:self forKeyPath:@"contentOffset"];
        [self.scs removeObject:sc];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"] && [object isKindOfClass:[UIScrollView class]]) {
        BOOL scrollSet = [objc_getAssociatedObject(object, &kScrollIgnoreKey) boolValue];
        if (scrollSet) {
//            DDLogDebug(@"=sc remove my set");
            return;
        }
        
        CGFloat offsetY = ((UIScrollView *)object).contentOffset.y;
        CGFloat top = ((UIScrollView *)object).contentInset.top;
//        DDLogDebug(@"=sc offsetY:%@|insetsTop:%@",@(offsetY),@(top));
        CGFloat offsetFix = offsetY + top;
//        DDLogDebug(@"=sc fix:%@",@(offsetFix));
        if (self.delegate && [self.delegate respondsToSelector:@selector(offsetHandler:scrollDidScroll:fixOffsetY:)]) {
            [self.delegate offsetHandler:self scrollDidScroll:object fixOffsetY:offsetFix];
        }
        if (offsetFix < 0) {
            offsetFix = 0;
            // 在下拉
        } else if (offsetFix > self.scrollStopHover) {
            // 在上推
            offsetFix = self.scrollStopHover;
//            DDLogDebug(@"=sc scroll header stop");
            // 到达临界点,整体再更新下
            if (!self.fixOffset && offsetFix == self.scrollStopHover) {
//                DDLogDebug(@"=sc  originOffsetY[fix]:%@|top:%@|hover:%@|offsetFix:%@",@(offsetY),@(top),@(self.scrollStopHover),@(offsetFix));
                for ( int i = 0; i < self.scs.count; i++) {
                    UIScrollView *sc = self.scs[i];
                    if (sc == object) {
                        continue;
                    }
                    objc_setAssociatedObject(sc, &kScrollIgnoreKey, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
                    [sc setContentOffset:CGPointMake(0, -(top - self.scrollStopHover))];
                    objc_setAssociatedObject(sc, &kScrollIgnoreKey, @(NO), OBJC_ASSOCIATION_COPY_NONATOMIC);
                }
                self.fixOffset = YES;
            }
        } else {
//            DDLogDebug(@"=sc  originOffsetY:%@|top:%@|hover:%@|offsetFix:%@",@(offsetY),@(top),@(self.scrollStopHover),@(offsetFix));
            // 修正其他scrollView的偏移
            for ( int i = 0; i < self.scs.count; i++) {
                UIScrollView *sc = self.scs[i];
                if (sc == object) {
                    continue;
                }
                objc_setAssociatedObject(sc, &kScrollIgnoreKey, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
                [sc setContentOffset:((UIScrollView *)object).contentOffset];
                objc_setAssociatedObject(sc, &kScrollIgnoreKey, @(NO), OBJC_ASSOCIATION_COPY_NONATOMIC);
            }
            self.fixOffset = NO;
        }
        self.currentOffsetFix = offsetFix;
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, self.originHeaderFrame.origin.y - offsetFix, self.headerView.frame.size.width, self.headerView.frame.size.height);
    }
}

- (void)beginListern {
    for (UIScrollView *sc in self.scs) {
        objc_setAssociatedObject(sc, &kScrollIgnoreKey, @(NO), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (void)stopListern {
    for (UIScrollView *sc in self.scs) {
        objc_setAssociatedObject(sc, &kScrollIgnoreKey, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

@end
