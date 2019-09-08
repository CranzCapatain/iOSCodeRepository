//
//  SecondViewController.m
//  test
//
//  Created by 金峰 on 2018/2/3.
//  Copyright © 2018年 金峰. All rights reserved.
//

#import "SecondViewController.h"


int gcd(int a, int b) {
    int temp = 0;
    if (a < b) {
        temp = a;
        a = b;
        b = temp;
    }
    
    while (b != 0) {
        temp = a % b;
        a = b;
        b = temp;
    }
    
    return a;
    
}

@interface SecondViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SecondViewController

- (void)dealloc {
    __weak typeof(self) weakSelf;
    NSLog(@"%@",weakSelf);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate =self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];

}

- (UIScrollView *)pageSubScrollView {
    return self.tableView;
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"-%ld-",indexPath.row];;
    return cell;
}

@end
