//
//  CocoaBindViewController.m
//  test
//
//  Created by 李威 on 2021/9/2.
//  Copyright © 2021 李威. All rights reserved.
//

#import "CocoaBindViewController.h"
#import <ReactiveCocoa.h>

@interface CocoaBindViewController ()

@end

@implementation CocoaBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    void (^block)(void) = ^{
        
    };
}
//https://www.jianshu.com/p/bbedd964abea
- (void)createSignal {
/*1*/
    //.先创建信号signal，内部创建RACDynamicSignal，属性didSubscribe把block1 copy保存起来。返回一个RACDynamicSignal
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
/*8  block1*/
        [subscriber sendNext:@1];
        [subscriber sendNext:@2];
        [subscriber sendNext:@3];
        [subscriber sendCompleted];
        //        return nil;
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"signal dispose");
        }];
    }];
    
    //绑定源信号，生成绑定信号
    //bind操作实际上是直接生成绑定信号并返回，并且在生成绑定信号传入的didSubscriber block代码块中，
    //保存了bind传入的block，初始化了信号数组，并且订阅了源信号，
    //针对源信号发送信号的流程做了一些处理。（此时未执行，订阅才执行）
/*2   block2*/
    //当signal信号调用bind进行绑定，会调用block5
    RACSignal *bindSignal = [signal bind:^RACStreamBindBlock{
/*6*/
        return ^RACSignal *(NSNumber *value, BOOL *stop){
/*10  block3*/
            value = @(value.integerValue*2);
            return [RACSignal return:value];
        };
    }];
    
    //订阅绑定信号
    //订阅绑定信号就是保存了nextBlock,并且创建订阅者，实现信号的didSubscriber block代码块。
/*4*/
    //当订阅者开始订阅bindSignal的时候，也就是subscribeNext内部会创建订阅者，然后self.didSubscribe(subscriber)，即执行didSubscribe的block，即执行block6
    [bindSignal subscribeNext:^(id x) {
/*14  block4*/
        NSLog(@"subscribe value = %@",x);
    }];
    
    //进入bind函数
}

@end
