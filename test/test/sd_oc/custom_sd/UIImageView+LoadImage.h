//
//  UIImageView+LoadImage.h
//  test
//
//  Created by 李威 on 2021/6/21.
//  Copyright © 2021 李威. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (LoadImage)
@property (nonatomic, strong) NSString *url;
- (void)loadImageWithURL:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
