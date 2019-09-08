//
//  IAScrollOffsetHandler.m
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import "IAScrollOffsetHandler.h"

@interface IAScrollOffsetHandler ()
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, strong) NSMutableArray *scs;
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
        _scs = [NSMutableArray array];
    }
    return self;
}

- (void)addListernScrollView:(UIScrollView *)sc {
    if (!sc) {
        return;
    }
    [self.scs addObject:sc];
    [sc addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)removeListernSCrollView:(UIScrollView *)sc {
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
        CGFloat offsetY = ((UIScrollView *)object).contentOffset.y;
        CGFloat top = ((UIScrollView *)object).contentInset.top;
        NSLog(@"=offsetY:%@|insetsTop:%@",@(offsetY),@(top));
        CGFloat offsetFix = offsetY + top;
        NSLog(@"=fix:%@",@(offsetFix));
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x, self.headerView.frame.origin.y, self.headerView.frame.size.width, self.headerView.frame.size.height);
    }
}

@end
