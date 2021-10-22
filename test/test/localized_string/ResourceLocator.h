//
//  ResourceLocator.h
//  test
//
//  Created by 李威 on 2021/5/10.
//  Copyright © 2021 李威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define VLocalizedString(key, plural) \
    [ResourceLocator.shared localizedStringForKey:(key) withPlural:(plural)]

@interface ResourceLocator : NSObject
+ (instancetype)shareInstace;
@end

NS_ASSUME_NONNULL_END
