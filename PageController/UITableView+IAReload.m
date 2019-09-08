//
//  UITableView+IAReload.m
//  YunJiBuyer
//
//  Created by JinFeng on 2019/8/22.
//  Copyright © 2019 浙江集商优选电子商务有限公司. All rights reserved.
//

#import "UITableView+IAReload.h"
#import <objc/runtime.h>

@implementation UITableView (IAReload)

+ (void)load {
    Method m1 = class_getInstanceMethod(self, @selector(reloadData));
    Method m2 = class_getInstanceMethod(self, @selector(ia_reloadData));
    method_exchangeImplementations(m1, m2);
}

- (void)ia_reloadData {
    BOOL is = [objc_getAssociatedObject(self, "isIAScroll") boolValue];
    BOOL first = [objc_getAssociatedObject(self, "IAFirstLoad") boolValue];
    // 准备刷新
    if (is) {
        if (first) {
            NSLog(@"=ia begin reload");
        }
    }
    [self ia_reloadData];
    // 刷新结束
    if (is) {
        if (first) {
            NSLog(@"=ia end reload");
            // 去获取此时的偏移
            [[NSNotificationCenter defaultCenter] postNotificationName:IAListFirstReloadNotification object:self];
            objc_setAssociatedObject(self, "IAFirstLoad", @(NO), OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
}

@end
