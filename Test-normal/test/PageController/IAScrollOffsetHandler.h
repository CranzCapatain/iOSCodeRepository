//
//  IAScrollOffsetHandler.h
//  test
//
//  Created by JinFeng on 2019/8/18.
//  Copyright © 2019 金峰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IAScrollOffsetHandler : NSObject

- (instancetype)initWithHeaderView:(UIView *)headerView;

- (void)addListernScrollView:(UIScrollView *)sc;

- (void)removeListernSCrollView:(UIScrollView *)sc;

@property (nonatomic, assign) CGFloat scrollStopHover;

@end

NS_ASSUME_NONNULL_END
