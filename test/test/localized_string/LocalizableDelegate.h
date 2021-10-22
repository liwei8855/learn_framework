//
//  LocalizableDelegate.h
//  test
//
//  Created by 李威 on 2021/5/11.
//  Copyright © 2021 李威. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHCSVParser.h"
NS_ASSUME_NONNULL_BEGIN

@interface LocalizableDelegate : NSObject<CHCSVParserDelegate>
- (NSArray *)result;
@end

NS_ASSUME_NONNULL_END
