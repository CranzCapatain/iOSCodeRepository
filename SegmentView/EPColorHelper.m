//
//  EPColorHelper.m
//  KM
//
//  Created by JinFeng on 2018/11/29.
//  Copyright © 2018年 popo.netease.com. All rights reserved.
//

#import "EPColorHelper.h"

@implementation EPColorHelper

+ (EPRgb)readFromColor:(UIColor *)color {
    CGFloat red,green,blue,alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    EPRgb rgb;
    rgb.blue = blue;
    rgb.green = green;
    rgb.red = red;
    rgb.alpha = alpha;
    
    return rgb;
}

+ (NSString *)descriptionWithRgb:(EPRgb)rgb {
    return [NSString stringWithFormat:@"========== red:%lf,green:%lf,blue:%lf",rgb.red, rgb.green, rgb.blue];
}

@end
