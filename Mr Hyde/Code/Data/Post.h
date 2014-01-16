//
//  Post.h
//  Mr Hyde
//
//  Created by John Jones on 1/2/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "Page.h"

@interface Post : Page

@property (nonatomic) NSDate* date;

- (id)initWithAbsoluteFilePath:(NSString*)path andSite:(Site*)site error:(NSError**)error;

@end
