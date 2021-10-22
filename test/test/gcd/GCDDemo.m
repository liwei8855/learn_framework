//
//  GCDDemo.m
//  test
//
//  Created by 李威 on 2020/5/7.
//  Copyright © 2020 李威. All rights reserved.
/*
 核心概念：1.任务:执行什么操作
        2.队列：用来存放任务
 将任务添加到队列，gcd自动将队列中任务取出，
 放到对应线程中执行
 */
/*
 队列分两大类：1.并发队列（只在异步函数下有效）
            2.串行队列
*/
/*
 同步、异步(方法)：决定了要不要开新线程
    同步：在当前线程执行任务，不具备开启新线程能力
    异步：在新线程中执行任务，具备开启新线程能力，开几条线程由队列决定（串行只开一条，并发开多条）
 并发、串行：决定了任务执行方式
    并发：多个任务并发(同时)执行
    串行：一个任务执行完，再执行下一个
 */

#import "GCDDemo.h"

@implementation GCDDemo

//同步函数
- (void)sync{
    dispatch_sync(dispatch_get_main_queue(), ^{
        
    });
}
//异步函数
- (void)async{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

//主队列
- (void)main_queue {
    //自带特殊串行队列，主队列中任务，都会放主线程执行
    dispatch_queue_t main = dispatch_get_main_queue();
}

//串行队列
- (void)chuanxing {
    //创建队列
    //const char * _Nullable label队列名称
    //dispatch_queue_attr_t  _Nullable attr队列属性,一般用NULL
    dispatch_queue_t queue = dispatch_queue_create("queue_chuanxing", NULL);
//    dispatch_release(queue);//非arc需要手动释放队列
    
    /*队列名称可以在断点处找到对应的队列
     */
}

//默认全局并发队列
//供整个应用使用，不需要手动创建
- (void)global_queue{
    /*long identifier y优先级
        全局并发队列优先级
        #define DISPATCH_QUEUE_PRIORITY_HIGH 2 // 高
        #define DISPATCH_QUEUE_PRIORITY_DEFAULT 0 // 默认（中）
        #define DISPATCH_QUEUE_PRIORITY_LOW (-2) // 低
        #define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN // 后台
     unsigned long flags 暂时无用传0即可
     */
    dispatch_queue_global_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

//异步函数往并发队列添加任务
- (void)bingfa {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //添加任务到队列 具备开启新线程能力
    dispatch_async(queue, ^{
        NSLog(@"下载图片1=====%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"下载图片2=====%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"下载图片3=====%@",[NSThread currentThread]);
    });
    NSLog(@"主线程=====%@",[NSThread mainThread]);
    //同时开启三个子线程
}

//异步函数往串行队列添加任务
- (void)chuanxing1 {
    NSLog(@"主线程=====%@",[NSThread mainThread]);
    //创建串行队列
    /*p1:串行队列名称，c语言字符串
      p2:队列属性，一般串行队列不需要赋值属性，通常传NULL
     */
    dispatch_queue_t queue = dispatch_queue_create("chuanxing", NULL);
    dispatch_async(queue, ^{
        NSLog(@"下载图片1=====%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"下载图片2=====%@",[NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        NSLog(@"下载图片3=====%@",[NSThread currentThread]);
    });
    //会开启线程，但只开启一个线程
}

//同步函数往并发队列添加任务
- (void)bingfa1 {
    NSLog(@"主线程=====%@",[NSThread mainThread]);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        NSLog(@"下载图片1=====%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
       NSLog(@"下载图片2=====%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
       NSLog(@"下载图片3=====%@",[NSThread currentThread]);
    });
    //不会开启新线程，并发队列失去并发功能
}

//同步函数往串行队列添加任务
- (void)chuanxing2 {
    dispatch_queue_t queue = dispatch_queue_create("chuanxing", NULL);
    dispatch_sync(queue, ^{
        NSLog(@"下载图片1=====%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"下载图片2=====%@",[NSThread currentThread]);
    });
    dispatch_sync(queue, ^{
        NSLog(@"下载图片3=====%@",[NSThread currentThread]);
    });
    //不会新开启线程
}
@end
