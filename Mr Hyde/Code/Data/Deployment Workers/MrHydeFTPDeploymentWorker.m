//
//  MrHydeFTPDeploymentWorker.m
//  Mr Hyde
//
//  Created by John Jones on 1/25/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "MrHydeFTPDeploymentWorker.h"
#import "FTPManager.h"
#import "Deployment.h"

@interface MrHydeFTPDeploymentWorker ()

@property (nonatomic) FMServer* server;
@property (nonatomic) FTPManager* man;
@property (nonatomic) NSError* error;

- (void)backgroundOperation;
- (void)backgroundProgress:(NSNumber*)n;
- (void)backgroundComplete;

@end

@implementation MrHydeFTPDeploymentWorker

- (void)deploy {
    self.server = [FMServer serverWithDestination:self.deployment.url username:self.deployment.username password:self.deployment.password];
    [self performSelectorInBackground:@selector(backgroundOperation) withObject:nil];
}

- (void)backgroundOperation {
    self.man = [[FTPManager alloc] init];
    __block NSUInteger total = self.totalUploadSize;
    __block NSUInteger uploadedSoFar = 0;
    NSError* error;
    [self traverseSiteDirectories:^(NSString *localPath) {
        [self.man createNewFolder:localPath atServer:self.server];
    } andFiles:^(NSString *localPath, NSData *data) {
        [self.man uploadData:data withFileName:localPath toServer:self.server];
        uploadedSoFar += data.length;
        double pct = (double)uploadedSoFar / (double)total;
        [self performSelectorOnMainThread:@selector(backgroundProgress:) withObject:@(pct) waitUntilDone:NO];
    } andError:&error];
    if (error) {
        self.error = error;
    }
    [self performSelectorOnMainThread:@selector(backgroundComplete) withObject:nil waitUntilDone:NO];
}

- (void)backgroundProgress:(NSNumber*)n {
    [self.delegate deploymentWorker:self progress:n.doubleValue];
}

- (void)backgroundComplete {
    if (self.error) {
        [self.delegate deploymentWorker:self encounteredError:self.error];
    } else {
        [self.delegate deploymentWorkerComplete:self];
    }
}



@end
