//
//  MrHydeDeploymentWorker.h
//  Mr Hyde
//
//  Created by John Jones on 1/25/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Deployment;
@class MrHydeDeploymentWorker;

@protocol MrHydeDeploymentWorkerDelegate

- (void)deploymentWorker:(MrHydeDeploymentWorker*)worker encounteredError:(NSError*)error;
- (void)deploymentWorker:(MrHydeDeploymentWorker *)worker progress:(double)pct;
- (void)deploymentWorkerComplete:(MrHydeDeploymentWorker *)worker;

@end

@interface MrHydeDeploymentWorker : NSObject

@property (nonatomic) Deployment* deployment;
@property (nonatomic) id<MrHydeDeploymentWorkerDelegate> delegate;
@property (nonatomic) NSUInteger totalUploadSize;

- (id)initWithDeployment:(Deployment*)deployment;
- (void)deploy;
- (void)traverseSiteDirectories:(void (^)(NSString* localPath))directoryCallback andFiles:(void (^)(NSString* localPath, NSData* data))fileCallback andError:(NSError**)error;

@end
