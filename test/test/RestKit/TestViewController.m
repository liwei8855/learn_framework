//
//  TestViewController.m
//  ViewTest
//
//  Created by 李威 on 2019/2/25.
//  Copyright © 2019年 李威. All rights reserved.
//

#import "TestViewController.h"
#import <RestKit/RestKit.h>
@interface DataClass:NSObject
@end
@implementation DataClass


@end

@interface RequestHeaderObject : NSObject

@end
@implementation RequestHeaderObject


@end

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)testPromise {
    NSString *baseUrlString = @"https://news-af.op-mobile.opera.com/v1/localnews/user/update?country=ng&language=en";
    
//    {"city_list":[{"city_id":"city_ng_027"},{"city_id":"city_ng_043"},{"city_id":"city_ng_026"},{"city_id":"city_ng_004"}],"news_device_id":"19b15221fc190f4113faca1fe657ab2fb5538822"}
    
    //request manager
    AFRKHTTPClient *client = [[AFRKHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrlString]];

    RKObjectManager *manager = [[RKObjectManager alloc] initWithHTTPClient:client];

    //request object
    [manager setRequestSerializationMIMEType:RKMIMETypeJSON];
    RKRequestDescriptor *requestDescriptor = [self requestDescripter];
    [manager addRequestDescriptor:requestDescriptor];
    
    //response
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[DataClass class]];
    [mapping addAttributeMappingsFromArray:@[@"name"]];
//    mapping mappingForSourceKeyPath:<#(NSString *)#>
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodPOST pathPattern:nil keyPath:@"response.venues" statusCodes:[NSIndexSet indexSetWithIndex:200]];
}

- (RKRequestDescriptor *)requestDescripter {
    RKObjectMapping *mapping = [RKObjectMapping requestMapping];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"deviceId":@"news_device_id",
                                                  @"cityList":@"city_list"
                                                  }];
    return [RKRequestDescriptor requestDescriptorWithMapping:mapping objectClass:[RequestHeaderObject class] rootKeyPath:nil method:RKRequestMethodPOST];
}


@end
