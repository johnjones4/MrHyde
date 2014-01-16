//
//  Site.h
//  Mr Hyde
//
//  Created by John Jones on 12/31/13.
//  Copyright (c) 2013 Phoenix4. All rights reserved.
//

static NSString* ContentsChangedNotification = @"contents_changed";

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;
@class Post;
@class PageFolder;

typedef enum NBool {
    nFalse = 0,
    nTrue = 1,
    nNull = 2
    } NBool;

@class Deployment;

@interface Site : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSSet *deployments;

@property (nonatomic) NSArray* plugins;
@property (nonatomic) NSArray* layouts;
@property (nonatomic) NSArray* posts;
@property (nonatomic) PageFolder* pages;

@property (nonatomic) NSString* source;
@property (nonatomic) NSString* destination;
@property (nonatomic) NSString* pluginsDir;
@property (nonatomic) NSString* layoutsDir;
@property (nonatomic) NSArray* include;
@property (nonatomic) NSArray* exclude;
@property (nonatomic) NSArray* keepFiles;
@property (nonatomic) NSString* host;
@property (nonatomic) NSNumber* port;
@property (nonatomic) NSString* baseURL;
@property (nonatomic) NSString* url;

@property (readonly) BOOL isValidSite;
@property (readonly) NSString* configFilePath;
@property (readonly) NSString* defaultLayout;

- (BOOL)validateSitePath:(NSError**)error;

- (BOOL)initializeNewSite:(NSError**)error;
- (BOOL)initializeExistingSite:(NSError**)error;
- (BOOL)loadSite:(NSError**)error;
- (BOOL)saveSite:(NSError**)error;

- (BOOL)readSiteConfig:(NSError**)error;
- (BOOL)saveSiteConfig:(NSError**)error;

- (BOOL)readSiteLayouts:(NSError**)error;
- (BOOL)readSitePages:(NSError**)error;
- (BOOL)readSitePosts:(NSError**)error;

- (Post*)findPostForPath:(NSString*)path;
- (Page*)findPageForPath:(NSString*)path;

- (void)addPost:(Post*)post error:(NSError**)error;

+ (NBool)parseNBool:(NSString*)b;
+ (NSString*)nBoolToString:(NBool)b;


@end

@interface Site (CoreDataGeneratedAccessors)

- (void)addDeploymentsObject:(Deployment *)value;
- (void)removeDeploymentsObject:(Deployment *)value;
- (void)addDeployments:(NSSet *)values;
- (void)removeDeployments:(NSSet *)values;

@end