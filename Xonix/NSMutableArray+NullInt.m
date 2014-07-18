//
//  NSMutableArray+NullInt.m
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "NSMutableArray+NullInt.h"

@implementation NSMutableArray (NullInt)

+(NSMutableArray *)mutableNullArrayWithSize:(NSUInteger)size
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:size];
    for (int i = 0; i < size; i++) {
        [returnArray addObject:[NSNull null]];
    }
    return returnArray;
}

+(NSMutableArray *)mutableNullArraysWithVisualFormat:(NSString *)string
{
    NSMutableArray *returnArray = nil;
    NSRange bitRange;
    if ((bitRange = [string rangeOfString:@"^\\[\\d+]" options:NSRegularExpressionSearch]).location != NSNotFound) {
        NSUInteger size = [[string substringWithRange:NSMakeRange(1, bitRange.length - 2)] integerValue];
        if (string.length == bitRange.length) {
            returnArray = [self mutableNullArrayWithSize:size];
        } else {
            returnArray = [[NSMutableArray alloc] initWithCapacity:size];
            NSString *nextLevel = [string substringWithRange:NSMakeRange(bitRange.length, string.length - bitRange.length)];
            NSMutableArray *subArray;
            for (int i = 0; i < size; i++) {
                subArray = [self mutableNullArraysWithVisualFormat:nextLevel];
                if (subArray) {
                    [returnArray addObject:subArray];
                } else {
                    return nil;
                }
            }
        }
    } else {
        return nil;
    }
    return returnArray;
}

@end
