//
//  MrHydeAppDelegate.m
//  Mr Hyde
//
//  Created by John Jones on 12/30/13.
//  Copyright (c) 2013 Phoenix4. All rights reserved.
//

#import "MrHydeAppDelegate.h"
#import "Site.h"
#import "MrHydeSiteWindowController.h"

@implementation MrHydeAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.siteWindows = [[NSMutableDictionary alloc] init];
    [self refreshData];
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(handleSaveNotification:) name:NSManagedObjectContextDidSaveNotification object:self.managedObjectContext];
}

- (void)applicationDidBecomeActive:(NSNotification *)aNotification {
    [self.window makeKeyAndOrderFront:self];
}

- (void)handleSaveNotification:(NSNotification *)notification {
    [self refreshData];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.phoenix4.Mr_Hyde" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.phoenix4.Mr_Hyde"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Mr_Hyde" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Mr_Hyde.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)refreshData {
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(openSite)];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Site" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setSortDescriptors:self.tableView.sortDescriptors];
    NSError *error;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (array != nil) {
        self.sites = array;
        [self.tableView reloadData];
    }
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    [self.deleteSiteButton setEnabled: self.tableView.selectedRowIndexes.count > 0];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return false;
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return self.sites.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    Site* site = [self.sites objectAtIndex:rowIndex];
    return [site valueForKey:aTableColumn.identifier];
}

- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors {
    [self refreshData];
}

#pragma mark - actions

- (IBAction)deleteSite:(id)sender {
    NSIndexSet* set = self.tableView.selectedRowIndexes;
    [set enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Site* site = [self.sites objectAtIndex:idx];
        [self.managedObjectContext deleteObject:site];
        [self.managedObjectContext save:nil];
    }];
}

- (IBAction)addSite:(id)sender {
    [NSApp beginSheet:self.addSitePanel modalForWindow:self.tableView.window modalDelegate:self didEndSelector:@selector(didEndSheet:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)addSheetCanceled:(id)sender {
    [NSApp endSheet:self.addSitePanel];
}

- (IBAction)addSheetCompleted:(id)sender {
    NSString* ident = self.addSiteTabs.selectedTabViewItem.identifier;
    if ([ident isEqualToString:@"new"]) {
        NSString* path = self.anewSitePathField.stringValue;
        NSString* name = self.anewSiteNameField.stringValue;
        Site* site = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:self.managedObjectContext];
        site.path = path;
        site.name = name;
        NSError* initError;
        if ([site initializeNewSite:&initError]) {
            [self.managedObjectContext save:nil];
            [NSApp endSheet:self.addSitePanel];
            [self openWindowForSite:site];
        } else if (initError) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            alert.messageText = initError.localizedDescription;
            alert.alertStyle = NSCriticalAlertStyle;
            [alert runModal];
            [self.managedObjectContext deleteObject:site];
        }
    } else if ([ident isEqualToString:@"existing"]) {
        NSString* path = self.existingSitePathField.stringValue;
        Site* site = [NSEntityDescription insertNewObjectForEntityForName:@"Site" inManagedObjectContext:self.managedObjectContext];
        site.path = path;
        NSError* initError;
        if ([site initializeExistingSite:&initError]) {
            [self.managedObjectContext save:nil];
            [NSApp endSheet:self.addSitePanel];
            [self openWindowForSite:site];
        } else if (initError) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            alert.messageText = initError.localizedDescription;
            alert.alertStyle = NSCriticalAlertStyle;
            [alert runModal];
            [self.managedObjectContext deleteObject:site];
        }
    }
}

- (IBAction)newSitePathButtonSelected:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    [panel beginWithCompletionHandler:^(NSInteger result) {
        self.anewSitePathField.stringValue = panel.directoryURL.path;
    }];
}

- (IBAction)existingSitePathButtonSelected:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = YES;
    panel.canChooseFiles = NO;
    [panel beginWithCompletionHandler:^(NSInteger result) {
        self.existingSitePathField.stringValue = panel.directoryURL.path;
    }];
}

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [sheet orderOut:self];
}

- (void)openSite {
    NSInteger i = self.tableView.clickedRow;
    if (i < self.sites.count) {
        Site* site = [self.sites objectAtIndex:i];
        [self openWindowForSite:site];
    }
}

- (void)openWindowForSite:(Site*)site {
    NSString* key = site.objectID.URIRepresentation.description;
    MrHydeSiteWindowController* controller = [self.siteWindows objectForKey:key];
    if (controller) {
        [controller.window makeKeyAndOrderFront:self];
    } else {
        controller = [[MrHydeSiteWindowController alloc] initWithWindowNibName:@"Site"];
        controller.site = site;
        [self.siteWindows setValue:controller forKey:key];
        [controller showWindow:self];
        [controller.window makeKeyAndOrderFront:self];
    }
}

@end
