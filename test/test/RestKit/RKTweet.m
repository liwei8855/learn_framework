//
//  RKTweet.m
//  test
//
//  Created by 李威 on 2020/4/20.
//  Copyright © 2020 李威. All rights reserved.
//

#import "RKTweet.h"
#import <RestKit.h>

@implementation RKTweet

+ (RKObjectMapping *)jsonMapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[RKTweet class]];
    [mapping addAttributeMappingsFromDictionary:@{
        @"user.name":   @"username",
        @"user.id":     @"userID",
        @"text":        @"text"
    }];
    return mapping;
}

@end
