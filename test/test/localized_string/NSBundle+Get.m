//
//  NSBundle+Get.m
//  test
//
//  Created by 李威 on 2021/5/10.
//  Copyright © 2021 李威. All rights reserved.
//

#import "NSBundle+Get.h"

@implementation NSBundle (Get)
+ (NSBundle *)bundleWithBundleName:(NSString *)bundleName podName:(NSString *)podName {
    if (bundleName==nil && podName==nil) {
        @throw @"bundleName和podName不能同时为空";
    } else if (bundleName==nil) {
        bundleName = podName;
    } else if (podName==nil) {
        podName = bundleName;
    }
    
    if ([bundleName containsString:@".bundle"]) {
        bundleName = [bundleName componentsSeparatedByString:@".bundle"].firstObject;
    }
    return nil;
}
@end
