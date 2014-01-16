//
//  MrHydeAppDelegate.h
//  Mr Hyde
//
//  Created by John Jones on 12/30/13.
//  Copyright (c) 2013 Phoenix4. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Site;

@interface MrHydeAppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel *addSitePanel;
@property (assign) IBOutlet NSTableView* tableView;
@property (assign) IBOutlet NSToolbarItem *deleteSiteButton;
@property (assign) IBOutlet NSTextField *anewSiteNameField;
@property (assign) IBOutlet NSTextField *anewSitePathField;
@property (assign) IBOutlet NSTextField *existingSitePathField;
@property (weak) IBOutlet NSTabView *addSiteTabs;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) NSMutableDictionary* siteWindows;
@property (nonatomic) NSArray* sites;

- (IBAction)saveAction:(id)sender;
- (void)openSite;
- (IBAction)deleteSite:(id)sender;
- (IBAction)addSite:(id)sender;
- (IBAction)addSheetCanceled:(id)sender;
- (IBAction)addSheetCompleted:(id)sender;
- (IBAction)newSitePathButtonSelected:(id)sender;
- (IBAction)existingSitePathButtonSelected:(id)sender;

- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)refreshData;
- (void)handleSaveNotification:(NSNotification *)notification;

- (void)openWindowForSite:(Site*)site;

@end
