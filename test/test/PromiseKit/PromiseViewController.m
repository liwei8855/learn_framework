//
//  PromiseViewController.m
//  test
//
//  Created by 李威 on 2021/4/19.
//  Copyright © 2021 李威. All rights reserved.
//

#import "PromiseViewController.h"
#import <PromiseKit/PromiseKit.h>

@interface PromiseViewController ()
@property (nonatomic, strong) PMKPromise *promise;
@property (nonatomic, weak) PMKPromise *weakPromise;
@end

@implementation PromiseViewController
{
    PMKResolver resolve;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    //
    _promise = [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        _weakPromise = [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
            
        }];
    }];
//    _promise = [PMKPromise promiseWithResolver:resolve];
    [self later];
}

- (void)later {
    resolve(@"some fulfilled value");
}

@end
