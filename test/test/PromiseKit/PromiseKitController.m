//
//  PromiseKitController.m
//  test
//
//  Created by 李威 on 2020/5/27.
//  Copyright © 2020 李威. All rights reserved.
//

#import "PromiseKitController.h"
#import <PromiseKit/PromiseKit.h>
#import "PromiseViewController.h"
#import "PromiseView.h"

@interface PromiseKitController ()
@end

@implementation PromiseKitController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self promise_view];
}

- (void)promise_view {
    [UIView promiseWithDuration:0 animations:^{
        PromiseView *view = [[PromiseView alloc]initWithFrame:CGRectMake(30, 100, 100, 200)];
        view.backgroundColor = [UIColor redColor];
        [self.view addSubview:view];
    }];
}

- (void)promise_controller {
    [self promiseViewController:[PromiseViewController new] animated:YES completion:^{
            NSLog(@"completion");
    }].then(^(id value){
        NSLog(@"%@",value);
    });
}

- (void)promise_value {
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    PMKPromise *baseUrl = [PMKPromise promiseWithValue:url];
//    [PMKPromise promiseWithAdapter:^(PMKAdapter adapter) {
//            
//    }];
    baseUrl.then(^(NSURL *baseUrl){
        NSLog(@"%@",baseUrl);
    });
}

@end
