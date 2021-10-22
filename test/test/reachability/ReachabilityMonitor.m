//
//  ReachabilityMonitor.m
//  test
//
//  Created by 李威 on 2021/5/13.
//  Copyright © 2021 李威. All rights reserved.
//

#import "ReachabilityMonitor.h"
//#import <Availability.h>
//#import <UIKit/UIKit.h>
//#import <netinet/in.h>
//#import <netinet6/in6.h>
//#import <arpa/inet.h>
//#import <ifaddrs.h>
//#import <netdb.h>
#import <SystemConfiguration/SCNetworkReachability.h>

static const NSString *kNodeName = @"reachabilityNodeName";

typedef enum {
    NetworkReachabilityStatusUnknown          = -1,
    NetworkReachabilityStatusNotReachable     = 0,
    NetworkReachabilityStatusReachableViaWWAN = 1,
    NetworkReachabilityStatusReachableViaWiFi = 2,
} NetworkReachabilityStatus;

@interface ReachabilityMonitor()
@property (nonatomic, assign) SCNetworkReachabilityRef networkReachability;

@end
@implementation ReachabilityMonitor

- (void)startMonitoringNetworkReachability {
    [self stopMonitoringNetworkReachability];
    self.networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [kNodeName UTF8String]);
    if (!self.networkReachability) {
        return;
    }
    
//    __weak typeof(self)weakSelf = self;
    
}

- (void)stopMonitoringNetworkReachability {
    if (self.networkReachability) {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
}

@end
