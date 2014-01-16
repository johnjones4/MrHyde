//
//  PageFolder.h
//  Mr Hyde
//
//  Created by John Jones on 1/5/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Site;

@interface PageFolder : NSObject

@property (nonatomic) PageFolder* parent;
@property (nonatomic) NSString* name;
@property (nonatomic) Site* site;

@property (nonatomic,readonly) NSArray* contents;
@property (nonatomic,readonly) NSString* relativePath;
@property (nonatomic,readonly) NSString* absolutePath;

- (id)initWithSite:(Site*)site andName:(NSString*)name;
- (void)addItem:(id)item;
- (void)sortContents;

@end
