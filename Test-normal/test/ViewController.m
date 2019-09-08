//
//  ViewController.m
//  test
//
//  Created by 金峰 on 2018/2/3.
//  Copyright © 2018年 金峰. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <FMDB.h>
#import <sqlite3.h>
#import <objc/objc-sync.h>
#import "SecondViewController.h"

static NSString *imageUrl = @"https://ss1.baidu.com/6ONXsjip0QIZ8tyhnq/it/u=3683727301,212745740&fm=173&app=49&f=JPEG?w=640&h=426&s=562AF348CAEA7D1DDC2C6C1E030050C2";

@interface ViewController ()<UIScrollViewDelegate, IAScrollPageControllerDataSource>
@property (nonatomic, assign) BOOL hasData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = self;
    self.tabBarController.view.backgroundColor = [UIColor whiteColor];
    
    [self test_1];
}

- (void)test_1 {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"=test 获取到数据，开始构建vcs");
        self.hasData = YES;
        [self reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - IAScrollPageControllerDataSource

- (NSArray *)viewControllersForPage:(IAScrollPageController *)pageController {
    if (_hasData) {
        SecondViewController *s1 = [[SecondViewController alloc] init];
        SecondViewController *s2 = [[SecondViewController alloc] init];
        SecondViewController *s3 = [[SecondViewController alloc] init];
        SecondViewController *s4 = [[SecondViewController alloc] init];
        SecondViewController *s5 = [[SecondViewController alloc] init];
        SecondViewController *s6 = [[SecondViewController alloc] init];
        return @[s1,s2,s3,s4,s5,s6];
    }
    else {
        return nil;
    }
}

//- (UIView *)headerViewForPage:(IAScrollPageController *)pageController {
//    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0)];
//    redView.backgroundColor = [UIColor redColor];
//    return redView;
//}
//
//- (CGRect)rectOfHeaderViewForPage:(IAScrollPageController *)pageController {
//    return CGRectMake(0, 0, self.view.frame.size.width, 120);
//}


@end

