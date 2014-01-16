//
//  MrHydeSiteWindowController.h
//  Mr Hyde
//
//  Created by John Jones on 1/1/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Site;
@class Page;

@interface MrHydeSiteWindowController : NSWindowController <NSOutlineViewDataSource,NSOutlineViewDelegate,NSTextViewDelegate>


@property (weak) IBOutlet NSOutlineView *pagePostOutline;
@property (unsafe_unretained) IBOutlet NSTextView *textEditor;
@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSTextField *nameField;
@property (weak) IBOutlet NSTextField *slugField;
@property (weak) IBOutlet NSButton *slugCheckbox;
@property (weak) IBOutlet NSPopUpButton *layoutSelect;
@property (weak) IBOutlet NSDatePicker *dateSelector;
@property (weak) IBOutlet NSPopUpButton *contentTypeSelect;

@property (nonatomic) BOOL dirty;
@property (nonatomic) Site* site;
@property (nonatomic) Page* currentPage;

- (IBAction)addPage:(id)sender;
- (IBAction)addPost:(id)sender;
- (IBAction)addFolder:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (IBAction)previewSite:(id)sender;
- (IBAction)PublishSite:(id)sender;
- (IBAction)customSlugChanged:(id)sender;
- (IBAction)layoutDropdownChanged:(id)sender;
- (IBAction)datePickerChanged:(id)sender;
- (IBAction)contentTypeChanged:(id)sender;

- (void)refreshLayoutList:(BOOL)withRead;

- (void)saveTimer:(NSTimer*)timer;
- (void)save;
- (void)readInterface;

@end
