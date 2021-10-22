//
//  LocalizableDelegate.m
//  test
//
//  Created by 李威 on 2021/5/11.
//  Copyright © 2021 李威. All rights reserved.
//

#import "LocalizableDelegate.h"

@interface LocalizableDelegate()
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) NSMutableArray *currentLine;
@property (nonatomic, strong) NSMutableArray *languages;
@property (nonatomic, strong) NSMutableDictionary *currentLocalizable;
@end
@implementation LocalizableDelegate

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    _lines = [[NSMutableArray alloc]init];
}

- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    self.currentLine = [[NSMutableArray alloc]init];
}

- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    [self.currentLine addObject:field];
}

- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [self.lines addObject:self.currentLine];
    _currentLine = nil;
}

- (void)parserDidEndDocument:(CHCSVParser *)parser {
    
}

- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    _lines = nil;
}

- (NSArray *)result {
    return [_lines copy];
}

@end
