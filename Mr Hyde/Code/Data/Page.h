//
//  Page.h
//  Mr Hyde
//
//  Created by John Jones on 1/2/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSString PageContentType;

static PageContentType* PageContentTypeHTML = @"html";
static PageContentType* PageContentTypeTextile = @"textile";
static PageContentType* PageContentTypeMarkdown = @"markdown";

@class Site;
@class PageFolder;

@interface Page : NSObject

@property (nonatomic,readonly) NSString* absolutePath;
@property (nonatomic,readonly) NSString* filename;
@property (nonatomic) NSString* previousFilename;
@property (nonatomic) PageFolder* parent;
@property (nonatomic) Site* site;
@property (nonatomic) NSString* title;
@property (nonatomic) NSString* layout;
@property (nonatomic) NSString* content;
@property (nonatomic) NSString* slug;
@property (nonatomic) PageContentType* contentType;

- (id)initWithAbsoluteFilePath:(NSString*)path andSite:(Site*)site andParent:(PageFolder*)parent error:(NSError**)error;
- (id)initWithSite:(Site*)site andParent:(PageFolder*)parent;

- (BOOL)parseFile:(NSError**)error;
- (BOOL)savePage:(NSError**)error;

@end
