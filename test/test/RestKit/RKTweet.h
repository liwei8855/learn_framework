//
//  RKTweet.h
//  test
//
//  Created by 李威 on 2020/4/20.
//  Copyright © 2020 李威. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class RKObjectMapping;
@interface RKTweet : NSObject
@property (nonatomic, copy) NSNumber *userID;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *text;
+ (RKObjectMapping *)jsonMapping;
@end

NS_ASSUME_NONNULL_END
