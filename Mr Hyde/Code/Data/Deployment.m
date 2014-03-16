//
//  Deployment.m
//  Mr Hyde
//
//  Created by John Jones on 12/31/13.
//  Copyright (c) 2013 Phoenix4. All rights reserved.
//

#import "Deployment.h"
#import "Site.h"
#import "MrHydeConnectionKitDeploymentWorker.h"
#import "MrHydeS3DeploymentWorker.h"

@implementation Deployment

@dynamic name;
@dynamic type;
@dynamic username;
@dynamic password;
@dynamic site;
@dynamic url;

- (MrHydeDeploymentWorker*)generateWorker {
    if ([self.type isEqualToString:kDeploymentTypeS3]) {
        return [[MrHydeConnectionKitDeploymentWorker alloc] initWithDeployment:self];
    } else {
        return [[MrHydeS3DeploymentWorker alloc] initWithDeployment:self];
    }
}

@end
