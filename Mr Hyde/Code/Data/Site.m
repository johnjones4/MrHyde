//
//  Site.m
//  Mr Hyde
//
//  Created by John Jones on 12/31/13.
//  Copyright (c) 2013 Phoenix4. All rights reserved.
//

#import "Site.h"
#import "Deployment.h"
#import "YAMLSerialization.h"
#import "Post.h"
#import "Page.h"
#import "NSArray+ContainsNSString.h"
#import "PageFolder.h"

@interface Site()

- (BOOL)traverseDirectory:(NSString*)dir withFolder:(PageFolder*)folder error:(NSError**)error;
- (void)handleChangeNotification:(NSNotification *)notification;
+ (Page*)recusrivePageSearch:(NSString*)path forFolder:(PageFolder*)folder;

@end

@implementation Site

@dynamic name;
@dynamic path;
@dynamic deployments;

@synthesize source,destination,pluginsDir,layoutsDir,include,exclude,keepFiles,host,port,baseURL,url,plugins,layouts,posts,pages;

#pragma mark - Readyonly props

- (BOOL)isValidSite {
    return [self validateSitePath:nil];
}

- (NSString*)configFilePath {
    return [self.path stringByAppendingPathComponent:@"_config.yml"];
}

- (NSString*)defaultLayout {
    if ([self.layouts containsString:@"default"]) {
        return @"default";
    } else if (self.layouts.count > 0) {
        return [self.layouts objectAtIndex:0];
    } else {
        return nil;
    }
}

#pragma mark - Property Overrides

- (NSString*)source {
    return source == nil ? @"" : source;
}

- (NSString*)destination {
    return destination == nil ? @"./_site" : destination;
}

- (NSString*)pluginsDir {
    return pluginsDir == nil ? @"./_plugins" : pluginsDir;
}

- (NSString*)layoutsDir {
    return layoutsDir == nil ? @"./_layouts" : layoutsDir;
}

- (NSArray*)include {
    return include == nil ? @[@".htaccess"] : include;
}

- (NSArray*)exclude {
    return exclude == nil ? @[] : exclude;
}

- (NSArray*)keepFiles {
    return keepFiles == nil ? @[@".git",@".svn"] : keepFiles;
}

- (NSString*)host {
    return host == nil ? @"0.0.0.0" : host;
}

- (NSNumber*)port {
    return port == nil ? @4000 : port;
}

- (NSString*)baseURL {
    return baseURL == nil ? @"/" : baseURL;
}

- (NSString*)url {
    return url == nil ? @"http://localhost:4000" : url;
}

#pragma mark - Filesystem Persistance

- (BOOL)initializeNewSite:(NSError**)error {
    return NO;
}

- (BOOL)initializeExistingSite:(NSError**)error {
    BOOL b = [self validateSitePath:error];
    if (b) b = [self loadSite:error];
    return b;
}

- (BOOL)validateSitePath:(NSError**)error {
    BOOL b;
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.path isDirectory:&b]) {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:101 userInfo:@{NSLocalizedDescriptionKey:@"The specified file path does not exist."}];
        return FALSE;
    }
    else if (!b) {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:102 userInfo:@{NSLocalizedDescriptionKey:@"The specified file path for this site is not a directory."}];
        return FALSE;
    }
    else if (![[NSFileManager defaultManager] fileExistsAtPath:self.configFilePath]) {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:103 userInfo:@{NSLocalizedDescriptionKey:@"There is no _config.yml file in the specified directory."}];
        return FALSE;
    }
    return TRUE;
}

- (BOOL)loadSite:(NSError**)error {
    BOOL b = [self readSiteConfig:error];
    if (b) b = [self readSiteLayouts:error];
    if (b) b = [self readSitePages:error];
    if (b) b = [self readSitePosts:error];
    return b;
}

- (BOOL)saveSite:(NSError**)error {
    BOOL b = [self saveSiteConfig:error];
    return b;
}

- (BOOL)readSiteConfig:(NSError**)error {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.configFilePath]) {
        NSInputStream *stream = [[NSInputStream alloc] initWithFileAtPath:self.configFilePath];
        NSError* yamlerror;
        NSArray* config = [YAMLSerialization YAMLWithStream:stream
                                                    options:kYAMLReadOptionStringScalars
                                                      error:&yamlerror];
        if (yamlerror && !config) {
            if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:104 userInfo:@{NSLocalizedDescriptionKey:@"Your site's _config.yml file is invalid."}];
            return NO;
        }
        
        if (config.count > 0) {
            NSDictionary* dict = [config objectAtIndex:0];
            
            self.name = [dict objectForKey:@"name"];
            self.source = [dict objectForKey:@"source"];
            self.destination = [dict objectForKey:@"destination"];
            self.pluginsDir = [dict objectForKey:@"plugins"];
            self.layoutsDir = [dict objectForKey:@"layouts"];
            self.include = [dict objectForKey:@"include"];
            self.exclude = [dict objectForKey:@"exclude"];
            self.keepFiles = [dict objectForKey:@"keep_files"];
            self.host = [dict objectForKey:@"host"];
            self.port = [dict objectForKey:@"port"] == nil ? nil : [NSNumber numberWithInt:[[dict objectForKey:@"port"] integerValue]];
            self.baseURL = [dict objectForKey:@"baseurl"];
            self.url = [dict objectForKey:@"url"];
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)saveSiteConfig:(NSError**)error {
    
    NSMutableDictionary* config = [[NSMutableDictionary alloc] init];
    
    if (self.name) [config setValue:self.name forKey:@"name"];
    if (self.source) [config setValue:self.source forKey:@"source"];
    if (self.destination) [config setValue:self.destination forKey:@"destination"];
    if (self.pluginsDir) [config setValue:self.pluginsDir forKey:@"plugins"];
    if (self.layoutsDir) [config setValue:self.layoutsDir forKey:@"layouts"];
    if (self.include) [config setValue:self.include forKey:@"include"];
    if (self.exclude) [config setValue:self.exclude forKey:@"exclude"];
    if (self.keepFiles) [config setValue:self.keepFiles forKey:@"keep_files"];
    if (self.host) [config setValue:self.host forKey:@"host"];
    if (self.port) [config setValue:self.port.description forKey:@"port"];
    if (self.baseURL) [config setValue:self.baseURL forKey:@"baseURL"];
    if (self.url) [config setValue:self.url forKey:@"url"];
    
    NSOutputStream* stream = [[NSOutputStream alloc] initToFileAtPath:self.configFilePath append:NO];
    NSError* saveError;
    
    [YAMLSerialization writeYAML:config
                        toStream:stream
                         options:kYAMLWriteOptionSingleDocument
                           error:&saveError];
    
    if (saveError != nil) {
        *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:105 userInfo:@{NSLocalizedDescriptionKey:@"Could not save _config.yml file."}];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)readSiteLayouts:(NSError**)error {
    NSError* fileError;
    NSString* path = [self.path stringByAppendingPathComponent:self.layoutsDir];
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&fileError];
    if (fileError == nil) {
        NSMutableArray* mlayouts = [[NSMutableArray alloc] initWithCapacity:files.count];
        for(NSString* layoutPath in files) {
            [mlayouts addObject:[layoutPath substringToIndex:[layoutPath rangeOfString:@"."].location]];
        }
        self.layouts = [[NSArray alloc] initWithArray:mlayouts];
        return YES;
    } else {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:106 userInfo:@{NSLocalizedDescriptionKey:@"Could not read layouts directory."}];
        return NO;
    }
}

- (BOOL)traverseDirectory:(NSString*)dir withFolder:(PageFolder*)folder error:(NSError**)error {
    NSString* absPath = [[self.path stringByAppendingString:self.source] stringByAppendingPathComponent:dir];
    NSError* error1;
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absPath error:&error1];
    if (error1 == nil) {
        for(NSString* file in files) {
            NSString* fileRelPath = [dir stringByAppendingPathComponent:file];
            NSString* fileAbsPath = [[self.path stringByAppendingPathComponent:fileRelPath] stringByStandardizingPath];
            if ([file rangeOfString:@"_"].location != 0 && [file rangeOfString:@"."].location != 0 && ![self.exclude containsString:fileRelPath]) {
                BOOL isDir;
                [[NSFileManager defaultManager] fileExistsAtPath:fileAbsPath isDirectory:&isDir];
                if (isDir) {
                    PageFolder* subFolder = [[PageFolder alloc] initWithSite:self andName:[file lastPathComponent]];
                    subFolder.parent = folder;
                    BOOL success = [self traverseDirectory:fileRelPath withFolder:subFolder error:error];
                    if (!success) {
                        return NO;
                    } else if (subFolder.contents.count > 0) {
                        [folder addItem:subFolder];
                        [folder sortContents];
                    }
                } else {
                    if ([file rangeOfString:@".html"].location != NSNotFound
                        || [file rangeOfString:@".textile"].location != NSNotFound
                        || [file rangeOfString:@".markdown"].location != NSNotFound) {
                        
                        Page* page = [self findPageForPath:fileAbsPath];
                        NSError* error2;
                       
                        if (!page) {
                            page = [[Page alloc] initWithAbsoluteFilePath:fileAbsPath andSite:self andParent:folder error:&error2];
                        }
                        if (page) [folder addItem:page];
                        if (!error2) [page parseFile:&error2];
                        if (error2) {
                            if (error) *error = error2;
                            return NO;
                        }
                    }
                }
            }
        }
        return YES;
    } else {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:107 userInfo:@{NSLocalizedDescriptionKey:@"Could not read pages."}];
        return NO;
    }
}

- (BOOL)readSitePages:(NSError**)error {
    PageFolder* root = [[PageFolder alloc] initWithSite:self andName:nil];
    if ([self traverseDirectory:self.source withFolder:root error:error]) {
        [root sortContents];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeNotification:) name:ContentsChangedNotification object:root];
        self.pages = root;
        return YES;
    } else {
        return NO;
    }
}

- (void)handleChangeNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:ContentsChangedNotification object:self];
}

- (BOOL)readSitePosts:(NSError**)error {
    NSString* postsDir = [[self.path stringByAppendingPathComponent:self.source] stringByAppendingPathComponent:@"_posts"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:postsDir]) {
        NSError* filesError;
        NSArray* postsFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:postsDir error:&filesError];
        if (filesError == nil) {
            NSMutableArray* mPosts = [[NSMutableArray alloc] initWithCapacity:postsFiles.count];
            for(NSString* postFile in postsFiles) {
                NSString* postFilePath = [[postsDir stringByAppendingPathComponent:postFile] stringByStandardizingPath];
                Post* post = [self findPostForPath:postFilePath];
                NSError* error1;
                if (!post) {
                    post = [[Post alloc] initWithAbsoluteFilePath:postFilePath andSite:self error:&error1];
                    if (post) [mPosts addObject:post];
                }
                if (!error1) [post parseFile:&error1];
                if (error1) {
                    if (error) *error = error1;
                    return NO;
                }
            }
            [mPosts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                Post* p1 = obj1;
                Post* p2 = obj2;
                return [p1.date compare:p2.date];
            }];
            self.posts = [[NSArray alloc] initWithArray:mPosts];
            return YES;
        } else {
            if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:107 userInfo:@{NSLocalizedDescriptionKey:@"Could not read posts."}];
            return NO;
        }
    } else {
        return NO;
    }
}

+ (NBool)parseNBool:(NSString*)b {
    if ([[b lowercaseString] isEqualToString:@"true"]) {
        return nTrue;
    } else if ([[b lowercaseString] isEqualToString:@"true"]) {
        return nFalse;
    } else {
        return nNull;
    }
}

+ (NSString*)nBoolToString:(NBool)b {
    if (b == nTrue) {
        return @"true";
    } else if (b == nFalse) {
        return @"false";
    } else {
        return nil;
    }
}

- (void)addPost:(Post*)post error:(NSError**)error {
    NSMutableArray* _posts = [self.posts mutableCopy];
    [_posts addObject:post];
    self.posts = [NSArray arrayWithArray:_posts];
}

- (Post*)findPostForPath:(NSString*)path {
    for(Post* post in self.posts) {
        if ([post.absolutePath isEqualToString:path]) {
            return post;
        }
    }
    return nil;
}

+ (Page*)recusrivePageSearch:(NSString*)path forFolder:(PageFolder*)folder {
    for(id object in folder.contents) {
        if ([object isKindOfClass:[Page class]] && [path isEqualToString:((Page*)object).absolutePath]) {
            return object;
        } else if ([object isKindOfClass:[PageFolder class]]) {
            Page* page = [Site recusrivePageSearch:path forFolder:object];
            if (page) return page;
        }
    }
    return nil;
}

- (Page*)findPageForPath:(NSString*)path {
    return [Site recusrivePageSearch:path forFolder:self.pages];
}

@end
