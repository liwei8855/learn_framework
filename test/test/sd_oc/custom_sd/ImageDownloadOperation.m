//
//  ImageDownloadOperation.m
//  test
//
//  Created by 李威 on 2021/6/21.
//  Copyright © 2021 李威. All rights reserved.
//

#import "ImageDownloadOperation.h"
#import "UIImageView+LoadImage.h"

static NSMutableDictionary *_sameTaskDict;
static NSLock *_lock;
@implementation ImageDownloadOperation

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sameTaskDict = [NSMutableDictionary new];
        _lock = [NSLock new];
    });
}

// 进入后台对缓存文件夹的大小进行检查  超过100MB 进行清理，删除规则
- (void)main {
    // 1 缓存
    NSData *data = [self loadImagefromCache];
    
    //取消下载
    BOOL (^cancelOperation)(void) = ^{
        if (!self.imageView) {// 释放了
            return YES;
        }
        
        if (![self.url isEqual:self.imageView.url]) {// 任务切换
            return YES;
        }
        
        return NO;
    };
    
    if (!data) {
        
        // 取消节点1
        if (cancelOperation) {
            return;
        }
        
        // 任务记录
        [_lock lock];
        if ([_sameTaskDict objectForKey:self.url]) {
            // 任务正在执行中
            // 如果任务已经存在了，直接返回，返回之前保存imageview
            NSMutableArray *sameTaskObjs = [_sameTaskDict objectForKey:self.url];
            [sameTaskObjs addObject:self.imageView];
            [_lock unlock];
            return;
        } else {
            [_sameTaskDict setObject:[NSMutableArray array] forKey:self.url];
        }
        [_lock unlock];
        
        
        
        // 2 下载
        data = [self downloadImageWithUrl:self.url];
        // 3 bitmap
        UIImage *bitmap = [UIImage imageWithData:data];// [self bitmapFromImageData:data];
        // 4 存储 和 1 对应起来的
        [self saveBitmapImage:bitmap];
        
        // 取消节点2
        if (cancelOperation) {
            return;
        }
        
        // 5 加载
        [self loadImage:bitmap];
        
        //为重复下载同一个image的任务赋值
        
        
    } else {
        // 5 加载
        [self loadImage:[UIImage imageWithData:data]];
    }
}

- (NSData *)loadImagefromCache {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [directories firstObject];
    NSString *fileName = [self.url stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *filePath = [document stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

/*在线程里又开了个线程*/
- (NSData *)downloadImageWithUrl:(NSString *)url {
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSData *imageData = nil;
    
    /*
     信号量作用：等网络请求成功之后再往下走 去返回正确的image
     否则image没有下载下来为nil，则返回data都是nil，请求数据并没有返回回来
     */
    // 同步 (用信号量操作)
    dispatch_semaphore_t sem = dispatch_semaphore_create(0); //创建信号
    
    NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {// 网络异常处理 未处理
            imageData = data;
        }
        dispatch_semaphore_signal(sem); //发送信号
    }];
    [task resume];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);//等待信号 (阻塞)
    
    return imageData;
}

- (UIImage *)bitmapFromImageData:(NSData *)data {
    UIImage *netImage = [UIImage imageWithData:data];
    if (!netImage) {
        return nil;
    }
    
    CGImageRef imageRef = netImage.CGImage;
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    // 获取一个bitmap上下文
    CGContextRef contextRef = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), CGImageGetColorSpace(imageRef), CGImageGetBitmapInfo(imageRef));
    
    // 在bitmap上下文上绘制图片
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    // 把bitmap上下文转化成CGImageRef
    CGImageRef backImageRef = CGBitmapContextCreateImage(contextRef);
    if (!backImageRef) {
        return nil;
    }
    
    // 把CGImageRef 转化成UIImage对象
    UIImage *bitmapImage = [UIImage imageWithCGImage:backImageRef];
    
    CGContextRelease(contextRef);
    CGImageRelease(backImageRef);
//    CFRelease(contextRef);
//    CFRelease(backImageRef);
    return bitmapImage;
}

- (void)saveBitmapImage:(UIImage *)image {
    NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [directories firstObject];
    NSString *fileName = [self.url stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *filePath = [document stringByAppendingPathComponent:fileName];
    NSData *imageData = UIImagePNGRepresentation(image);
    [imageData writeToFile:filePath atomically:YES];
}

- (void)loadImage:(UIImage *)image {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.imageView setImage:image];
    });
}

- (void)sameTasksHandle:(UIImage *)bitmap {
    [_lock lock];
    
    NSMutableArray *sameTasks = [_sameTaskDict objectForKey:self.url];
    [_sameTaskDict removeObjectForKey:self.url];
    [sameTasks enumerateObjectsUsingBlock:^(UIImageView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.url isEqual:self.url]) {// imageView是否任务切换
            //主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                obj.image = bitmap;
            });
        }
        
    }];
    [_lock unlock];
}
@end
