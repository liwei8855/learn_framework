//
//  UIImageView+LoadImage.m
//  test
//
//  Created by 李威 on 2021/6/21.
//  Copyright © 2021 李威. All rights reserved.
//

#import "UIImageView+LoadImage.h"
#import <objc/runtime.h>
#import "ImageDownloadOperation.h"

static NSOperationQueue *_operationQueue;

@implementation UIImageView (LoadImage)

+ (void)initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _operationQueue = [NSOperationQueue new];
    });
}

- (void)loadImageWithURL:(NSString *)url {
    ImageDownloadOperation *operation = [ImageDownloadOperation new];
    operation.url = url;
    operation.imageView = self;
    [_operationQueue addOperation:operation];
}

- (void)setUrl:(NSString *)url {
    objc_setAssociatedObject(self, @selector(url), url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)url {
    return objc_getAssociatedObject(self, _cmd);
}

@end
