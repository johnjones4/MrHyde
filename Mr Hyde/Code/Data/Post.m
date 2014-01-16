//
//  Post.m
//  Mr Hyde
//
//  Created by John Jones on 1/2/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "Post.h"
#import "Site.h"

@implementation Post

- (id)initWithAbsoluteFilePath:(NSString*)path andSite:(Site*)site error:(NSError**)error {
    if (self = [super initWithAbsoluteFilePath:path andSite:site andParent:nil error:error]) {
        NSString* filename = [[path lastPathComponent] stringByDeletingPathExtension];
        NSArray* filenameParts = [filename componentsSeparatedByString:@"-"];
        if (filenameParts.count > 3) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSDateComponents *components = [[NSDateComponents alloc] init];
            NSInteger day = [[filenameParts objectAtIndex:2] integerValue];
            NSInteger month = [[filenameParts objectAtIndex:1] integerValue];
            NSInteger year = [[filenameParts objectAtIndex:0] integerValue];
            [components setDay:day];
            [components setMonth:month];
            [components setYear:year];
            self.date = [calendar dateFromComponents:components];
            
            NSString* dateString = [NSString stringWithFormat:@"%@-%@-%@-",[filenameParts objectAtIndex:0],[filenameParts objectAtIndex:1],[filenameParts objectAtIndex:2]];
            self.slug = [filename substringFromIndex:dateString.length];
        }
    }
    return self;
}

#pragma mark - Readonly props

- (NSString*)absolutePath {
    NSString* filepath = [[[self.site.path stringByAppendingPathComponent:self.site.source] stringByAppendingPathComponent:@"_posts/"] stringByStandardizingPath];
    NSString* _absPath = [filepath stringByAppendingPathComponent:self.filename];
    return _absPath;
}

- (NSString*)filename {
    static NSDateFormatter* formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd";
    }
    return [NSString stringWithFormat:@"%@-%@.%@",[formatter stringFromDate:self.date],self.slug,self.contentType];
}

@end
