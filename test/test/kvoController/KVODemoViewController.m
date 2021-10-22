//
//  KVODemoViewController.m
//  test
//
//  Created by 李威 on 2021/8/25.
//  Copyright © 2021 李威. All rights reserved.
//

#import "KVODemoViewController.h"
#import "KVOController.h"
#import "Person.h"
#import "Dog.h"

@interface KVODemoViewController ()
@property (nonatomic, strong) Person *person;
@property (nonatomic, strong) Dog *dog;
@end

@implementation KVODemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [Person new];
    self.person.name = @"jim";
    self.person.dogName = @"erha";
    self.dog = [Dog new];
    
    [self addObserve];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
}
- (void)addObserve{
/*
 一、
 本类的分类中创建了一个FBKVOController
 负责处理本类所有需要添加观察的对象的kvo属性
 二、
 1.observe方法中有一个类 _FBKVOInfo 包装所有传入参数
 2.保存info
    NSMapTable<id, NSMutableSet<_FBKVOInfo *> *> *_objectInfosMap;
    object为key，NSMutableSet为infos 保存所有被观察的属性包装成的info
 3.添加监听
 _FBKVOSharedController是观察者，负责监听所有info
 内部NSHashTable<_FBKVOInfo *> *_infos;保存监听对象info
 
 三、本类dealloc的时候，分类中FBKVOController属性也会销毁
    此时FBKVOController的dealloc中执行unobserveAll并
    通过KVOInfoMap找到所有KVO的对象，并执行移除观察的操作
*/
    
/*
 注意：循环引用问题：FBKVOController -> KVOInfoMap -> Target ->Observer ->FBKVOController
 所以：在使用的过程中，target不能强引用observer，否则也会形成retain cycle
 则：_FBKVOInfo 中 __weak FBKVOController *_controller; weak修饰
 */
    [self.KVOController observe:self.person keyPath:@"move" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//        id newValue = change[NSKeyValueChangeNewKey];
//        change[FBKVONotificationKeyPathKey];
    }];
}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.dog.move = !self.dog.move;
}

@end
