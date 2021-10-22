//
//  RestKitController.m
//  test
//
//  Created by 李威 on 2020/4/20.
//  Copyright © 2020 李威. All rights reserved.
//

#import "RestKitController.h"
#import <RestKit.h>
#import "RKTweet.h"

@implementation RestKitController

- (void)query {
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:[RKTweet jsonMapping] method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/public_timeline.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        NSLog(@"The public timeline Tweets: %@", [result array]);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"error %@",error);
    }];
    [operation start];
}

- (void)request {
    NSURL *url = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/public_timeline.json"];
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:url];
    
}

- (void)demo {
    NSURL *baseURL = [NSURL URLWithString:@""];
//    AFRKHTTPClient
}

@end
