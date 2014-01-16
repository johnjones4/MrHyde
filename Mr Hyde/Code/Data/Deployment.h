//
//  Deployment.h
//  Mr Hyde
//
//  Created by John Jones on 12/31/13.
//  Copyright (c) 2013 Phoenix4. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

static NSString* kDeploymentTypeFTP = @"FTP";
static NSString* kDeploymentTypeSFTP = @"SFTP";
static NSString* kDeploymentTypeWebdav = @"WebDav";
static NSString* kDeploymentTypeS3 = @"S3";

@class Site;

@interface Deployment : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) Site *site;

@end
