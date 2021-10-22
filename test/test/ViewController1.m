//
//  ViewController1.m
//  test
//
//  Created by 李威 on 2020/4/11.
//  Copyright © 2020 李威. All rights reserved.
//

#import "ViewController1.h"
//#import <Masonry/Masonry.h>

@interface ViewController1 ()
@property (weak, nonatomic) IBOutlet UILabel *lbTest;

@end

@implementation ViewController1
/*
 equalTo和mas_equalTo实现是一样的
 
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    self.lbTest.layer.borderWidth = 2;
//    [self.lbTest setTextColor:[UIColor blueColor]];
    [self.lbTest setTintColor:[UIColor orangeColor]];
    
    UIView *view = [[UIView alloc]init];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
//    [view mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.top.height
//        make.leading.equalTo(self.view).offset(20);
//        make.centerY.equalTo(self.view.mas_centerY);
//        make.size.mas_equalTo(CGSizeMake(50, 50));
//    }];
}

@end
