//
//  Page.m
//  Mr Hyde
//
//  Created by John Jones on 1/2/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "Page.h"
#import "Site.h"
#import "YAMLSerialization.h"
#import "NSArray+ContainsNSString.h"
#import "PageFolder.h"

/*
 TODO: 
    Constructor for UI
 */

@implementation Page

- (id)initWithAbsoluteFilePath:(NSString*)path andSite:(Site*)isite andParent:(PageFolder*)iparent error:(NSError**)error {
    if (self = [super init]) {
        self.site = isite;
        self.parent = iparent;
        
        // Get slug
        self.slug = [[path lastPathComponent] stringByDeletingPathExtension];
        
        // Get content type
        NSString* extension = [path pathExtension];
        NSArray* acceptableContentTypes = @[PageContentTypeHTML,PageContentTypeTextile,PageContentTypeMarkdown];
        if ([acceptableContentTypes containsString:extension]) {
            self.contentType = extension;
        } else {
            if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:203 userInfo:@{NSLocalizedDescriptionKey:@"Page is not an acceptable content type."}];
            return self;
        }
    }
    return self;
}

- (id)initWithSite:(Site*)isite andParent:(PageFolder*)iparent {
    if (self = [super init]) {
        self.site = isite;
        self.parent = iparent;
        self.layout = [self.site defaultLayout];
        self.contentType = PageContentTypeHTML;
        self.content = @"";
    }
    return self;
}

- (BOOL)parseFile:(NSError**)error {
    NSError* fileError;
    self.previousFilename = self.absolutePath;
    NSString* rawFile = [[NSString alloc] initWithContentsOfFile:self.previousFilename encoding:NSUTF8StringEncoding error:&fileError];
    if (fileError == nil) {
        NSRange startRange = [rawFile rangeOfString:@"---\n"];
        NSRange endRange = [rawFile rangeOfString:@"\n---\n"];
        NSArray* yaml;
        NSError* yamlError;
        if (startRange.location != NSNotFound && endRange.location != NSNotFound) {
            NSRange yamlRange = NSMakeRange(NSMaxRange(startRange), endRange.location - NSMaxRange(startRange));
            NSString* yamlString = [rawFile substringWithRange:yamlRange];
            NSData* yamlData = [yamlString dataUsingEncoding:NSUTF8StringEncoding];
            yaml = [YAMLSerialization YAMLWithData:yamlData
                                           options:kYAMLReadOptionStringScalars
                                             error:&yamlError];
        }
        if (yaml != nil && yamlError == nil && yaml.count > 0) {
            NSDictionary* config = [yaml objectAtIndex:0];
            self.title = [config valueForKey:@"title"];
            self.layout = [config valueForKey:@"layout"] == nil ? self.site.defaultLayout : [config valueForKey:@"layout"];
            self.content = [[NSString alloc] initWithString:[rawFile substringFromIndex:NSMaxRange(endRange)]];
            BOOL trimmed = YES;
            while (trimmed) {
                trimmed = NO;
                if ([self.content rangeOfString:@"\n"].location == 0 || [self.content rangeOfString:@" "].location == 0) {
                    self.content = [[NSString alloc] initWithString:[self.content substringFromIndex:1]];
                    trimmed = YES;
                }
            }
            return true;
        } else {
            if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:201 userInfo:@{NSLocalizedDescriptionKey:@"Could not read page header YAML."}];
            return false;
        }
    } else {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:202 userInfo:@{NSLocalizedDescriptionKey:@"Could not read page file."}];
        return false;
    }
}

- (BOOL)savePage:(NSError**)error {
    NSError* yamlError;
    NSData* yaml = [YAMLSerialization dataFromYAML:@{
                                                     @"title": self.title,
                                                     @"layout": self.layout
                                                     }
                                           options:kYAMLWriteOptionSingleDocument
                                             error:&yamlError];
    if (yamlError || !yaml) {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:204 userInfo:@{NSLocalizedDescriptionKey:@"Could not write page header YAML."}];
        return NO;
    }
    
    NSString* yamlString = [[NSString alloc] initWithData:yaml encoding:NSUnicodeStringEncoding];
    yamlString = [yamlString substringToIndex:yamlString.length-4];
    yamlString = [yamlString stringByAppendingString:@"---\n\n"];
    

    NSString* output = [yamlString stringByAppendingString:self.content];

    NSError* fileError;
    [output writeToFile:self.absolutePath atomically:YES encoding:NSUTF8StringEncoding error:&fileError];
    if (fileError) {
        if (error) *error = [[NSError alloc] initWithDomain:@"MRHYDE" code:205 userInfo:@{NSLocalizedDescriptionKey:@"Could not write page file."}];
        return NO;
    }
    
    if (![self.previousFilename isEqualToString:self.absolutePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:self.previousFilename error:nil];
        self.previousFilename = self.absolutePath;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ContentsChangedNotification object:self];
    
    return YES;
}

#pragma mark - Readonly props

- (NSString*)absolutePath {
    if (self.parent) {
        NSString* path = [[self.parent.absolutePath stringByAppendingPathComponent:self.filename] stringByStandardizingPath];
        return path;
    } else {
        NSString* filePath = [[self.site.path stringByAppendingPathComponent:self.site.source] stringByStandardizingPath];
        NSString* _absPath = [filePath stringByAppendingPathComponent:self.filename];
        return _absPath;
    }
}

- (NSString*)filename {
    return [NSString stringWithFormat:@"%@.%@",self.slug,self.contentType];
}

@end
