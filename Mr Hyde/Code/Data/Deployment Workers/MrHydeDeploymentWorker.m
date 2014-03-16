//
//  MrHydeDeploymentWorker.m
//  Mr Hyde
//
//  Created by John Jones on 1/25/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "MrHydeDeploymentWorker.h"
#import "Deployment.h"
#import "Site.h"

@interface MrHydeDeploymentWorker()

+ (void)traverseDirectory:(NSString*)dir relativeTo:(NSString*)absRoot withCallbackforDirectories:(void (^)(NSString* localPath))directoryCallback andFiles:(void (^)(NSString* localPath, NSData* data))fileCallback andError:(NSError**)error;

@end

@implementation MrHydeDeploymentWorker

- (id)initWithDeployment:(Deployment*)deployment {
    if (self = [super init]) {
        self.deployment = deployment;
    }
    return self;
}

- (void)deploy {
    [NSException raise:@"Not implemented" format:nil];
}

+ (void)traverseDirectory:(NSString*)dir relativeTo:(NSString*)absRoot withCallbackforDirectories:(void (^)(NSString* localPath))directoryCallback andFiles:(void (^)(NSString* localPath, NSData* data))fileCallback andError:(NSError**)error {
    NSString* absPath = [absRoot stringByAppendingPathComponent:dir];
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absPath error:error];
    for(NSString* file in files) {
        BOOL isDir;
        NSString* localPath = [dir stringByAppendingPathComponent:file];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[absRoot stringByAppendingPathComponent:file] isDirectory:&isDir] && isDir) {
            directoryCallback(localPath);
            [MrHydeDeploymentWorker traverseDirectory:localPath relativeTo:absRoot withCallbackforDirectories:directoryCallback andFiles:fileCallback andError:error];
        } else {
            NSData* data = [[NSData alloc] initWithContentsOfFile:[absPath stringByAppendingPathComponent:file]];
            fileCallback(localPath,data);
        }
    }
}

- (void)traverseSiteDirectories:(void (^)(NSString* localPath))directoryCallback andFiles:(void (^)(NSString* localPath, NSData* data))fileCallback andError:(NSError**)error {
    [MrHydeDeploymentWorker traverseDirectory:self.deployment.site.destination relativeTo:self.deployment.site.path withCallbackforDirectories:directoryCallback andFiles:fileCallback andError:error];
}

- (NSUInteger)totalUploadSize {
    __block NSUInteger n = 0;
    [self traverseSiteDirectories:^(NSString *localPath) {
        //Do nothing
    } andFiles:^(NSString *localPath, NSData *data) {
        n += data.length;
    } andError:nil];
    return n;
}

@end
