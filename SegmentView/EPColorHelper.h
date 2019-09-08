//
//  EPColorHelper.h
//  KM
//
//  Created by JinFeng on 2018/11/29.
//  Copyright © 2018年 popo.netease.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

struct EPRgb {
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat alpha;
};
typedef struct EPRgb EPRgb;

NS_ASSUME_NONNULL_BEGIN

@interface EPColorHelper : NSObject
// 从color中读取颜色的rgb
+ (EPRgb)readFromColor:(UIColor *)color;
+ (NSString *)descriptionWithRgb:(EPRgb)rgb;

@end

NS_ASSUME_NONNULL_END
