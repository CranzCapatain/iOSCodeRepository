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

@class IAScrollOffsetHandler;
@protocol IAScrollOffsetDelegate <NSObject>

- (void)offsetHandler:(IAScrollOffsetHandler *)handler scrollDidScroll:(UIScrollView *)scrollView fixOffsetY:(CGFloat)fixOffsetY;

@end

@interface IAScrollOffsetHandler : NSObject

- (instancetype)initWithHeaderView:(UIView *)headerView;

- (void)addListernScrollView:(UIScrollView *)sc;

- (void)removeListernScrollView:(UIScrollView *)sc;
/// 悬停的位置
@property (nonatomic, assign) CGFloat scrollStopHover;

@property (nonatomic, weak) id<IAScrollOffsetDelegate>delegate;

@property (nonatomic, assign, readonly) CGFloat currentOffsetFix;

- (void)stopListern;

- (void)beginListern;

@end

NS_ASSUME_NONNULL_END
