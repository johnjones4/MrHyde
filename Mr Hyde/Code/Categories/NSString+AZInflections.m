//
//  NSString+AZInflections.m
//  Mr Hyde
//
//  Created by John Jones on 1/5/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "NSString+AZInflections.h"

@implementation NSString (AZInflections)

- (NSString *)slugalize
{
    NSString *separator = @"-";
    NSMutableString *slugalizedString = [NSMutableString string];

    // Remove all non ASCII characters
    NSError *nonASCIICharsRegexError = nil;
    NSRegularExpression *nonASCIICharsRegex = [NSRegularExpression regularExpressionWithPattern:@"[^\\x00-\\x7F]+"
                                                                                        options:0
                                                                                          error:&nonASCIICharsRegexError];
    slugalizedString = [[nonASCIICharsRegex stringByReplacingMatchesInString:self
                                                                     options:0
                                                                       range:NSMakeRange(0, slugalizedString.length)
                                                                withTemplate:@""] mutableCopy];
    
    // Turn non-slug characters into separators
    NSError *nonSlugCharactersError = nil;
    NSRegularExpression *nonSlugCharactersRegex = [NSRegularExpression regularExpressionWithPattern:@"[^a-z0-9\\-_\\+]+"
                                                                                            options:NSRegularExpressionCaseInsensitive
                                                                                              error:&nonSlugCharactersError];
    slugalizedString = [[nonSlugCharactersRegex stringByReplacingMatchesInString:slugalizedString
                                                                         options:0
                                                                           range:NSMakeRange(0, slugalizedString.length)
                                                                    withTemplate:separator] mutableCopy];
    
    // No more than one of the separator in a row
    NSError *repeatingSeparatorsError = nil;
    NSRegularExpression *repeatingSeparatorsRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"%@{2,}", separator]
                                                                                              options:0
                                                                                                error:&repeatingSeparatorsError];
    slugalizedString = [[repeatingSeparatorsRegex stringByReplacingMatchesInString:slugalizedString
                                                                           options:0
                                                                             range:NSMakeRange(0, slugalizedString.length)
                                                                      withTemplate:separator] mutableCopy];
    
    // Remove leading/trailing separator
    slugalizedString = [[slugalizedString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]] mutableCopy];
    
    return [slugalizedString lowercaseString];
}

@end
