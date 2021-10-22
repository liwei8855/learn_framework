//
//  ImageDownloadOperation.h
//  test
//
//  Created by 李威 on 2021/6/21.
//  Copyright © 2021 李威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageDownloadOperation : NSOperation
@property (nonatomic, copy) NSString *url;
@property (nonatomic, weak) UIImageView *imageView;
@end

NS_ASSUME_NONNULL_END
