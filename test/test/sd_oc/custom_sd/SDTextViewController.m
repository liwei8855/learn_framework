//
//  SDTextViewController.m
//  test
//
//  Created by 李威 on 2021/6/21.
//  Copyright © 2021 李威. All rights reserved.
//

/*
 解码后的图片， 进行存储的时候，又进行了压缩，disk存储的是 压缩的，
 存的时候， 把解码的图片又重新编码（png/jpg）
 当从disk去拿图片的时候，是不是又要解压，（我们可以存解码后的图片bitmap）
 bitmap（ RGBARGBA）{前100字节是文件属性，RGBA（100bytes文件属性数据） RGBA }
 */
/*  SD简化版工具
 
 1 缓存 （第一次加载图片，网络操作，获取网络图片， 存本地（bitmap），加载图片）
 
 2 bitmap (bitmap格式，线程里面进行操作) （优化：1 减少任务量， 2 转移任务量 减轻主线程压力（当前任务有哪些， 1 我自己的业务，2系统底层做了什么知道））
 
 3 1 当uiimageview正在加载一个图片 urlA，由于网速有点慢，去加载另外一个urlB的时候，怎么取消上一个任务
   2 去重， uiimageviewA  uiimageviewB 同时加载 urlC时候，这个图片还没有从网络上下载下来，怎么操作
 
*/

#import "SDTextViewController.h"
#import <SDWebImage/SDWebImage.h>
#import "UIImageView+LoadImage.h"

@interface SDTextViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SDTextViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 80, 200, 300)];
    self.imageView.backgroundColor = UIColor.redColor;
    [self.view addSubview:self.imageView];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *url = @"http://img.hb.aicdn.com/0f608994c82c2efce030741f233b29b9ba243db81ddac-RSdX35_fw658";
//    self.imageView sd_setImageWithURL:<#(nullable NSURL *)#>
    [self.imageView loadImageWithURL:url];
}

@end
