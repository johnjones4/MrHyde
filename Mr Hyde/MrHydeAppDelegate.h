//
//  MrHydeAppDelegate.h
//  Mr Hyde
//
//  Created by John Jones on 12/30/13.
//  Copyright (c) 2013 Phoenix4. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MrHydeAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
