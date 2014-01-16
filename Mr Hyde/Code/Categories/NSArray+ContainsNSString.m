//
//  NSArray+ContainsNSString.m
//  Mr Hyde
//
//  Created by John Jones on 1/2/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "NSArray+ContainsNSString.h"

@implementation NSArray (ContainsNSString)

- (BOOL)containsString:(NSString*)string {
    for(NSString* str in self) {
        if ([str isEqualToString:string]) {
            return true;
        }
    }
    return false;
}

@end
