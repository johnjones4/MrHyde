//
//  PageFolder.m
//  Mr Hyde
//
//  Created by John Jones on 1/5/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "PageFolder.h"
#import "Site.h"
#import "Page.h"

//TODO handle page save on name change
//Alerts on name change

@interface PageFolder () {
    NSMutableArray* mContents;
}

- (void)handleChangeNotification:(NSNotification *)notification;

@end

@implementation PageFolder

- (id)initWithSite:(Site*)isite andName:(NSString*)iname {
    if (self = [super init]) {
        self.name = iname;
        self.site = isite;
        mContents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSArray*)contents {
    return [NSArray arrayWithArray:mContents];
}

- (void)addItem:(id)item {
    [mContents addObject:item];
    [[NSNotificationCenter defaultCenter] postNotificationName:ContentsChangedNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeNotification:) name:ContentsChangedNotification object:item];
}

- (void)handleChangeNotification:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:ContentsChangedNotification object:self];
}

- (void)sortContents {
    [mContents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString* str1 = [obj1 isKindOfClass:[PageFolder class]] ? ((PageFolder*)obj1).name : ((Page*)obj1).title;
        NSString* str2 = [obj2 isKindOfClass:[PageFolder class]] ? ((PageFolder*)obj2).name : ((Page*)obj2).title;
        return [str1 compare:str2];
    }];
    for (id item in self.contents) {
        if ([item isKindOfClass:[PageFolder class]]) {
            [((PageFolder*)item) sortContents];
        }
    }
}

- (NSString*)relativePath {
    if (self.parent) {
        NSString* path = [[self.parent.relativePath stringByAppendingPathComponent:self.name] stringByStandardizingPath];
        return path;
    } else if (self.name != nil) {
        return self.name;
    } else {
        return @"./";
    }
}

- (NSString*)absolutePath {
    NSString* sitePath = [[self.site.path stringByAppendingPathComponent:self.site.source] stringByStandardizingPath];
    return [sitePath stringByAppendingPathComponent:self.relativePath];
}

@end
