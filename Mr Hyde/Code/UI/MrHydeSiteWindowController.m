//
//  MrHydeSiteWindowController.m
//  Mr Hyde
//
//  Created by John Jones on 1/1/14.
//  Copyright (c) 2014 Phoenix4. All rights reserved.
//

#import "MrHydeSiteWindowController.h"
#import "Site.h"
#import "PageFolder.h"
#import "Page.h"
#import "Post.h"
#import "NSString+AZInflections.h"

@interface MrHydeSiteWindowController () {
    BOOL reloadMutex;
}

- (void)handleChangeNotification:(NSNotification *)notification;

@end

@implementation MrHydeSiteWindowController

@synthesize currentPage;

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    reloadMutex = NO;
    
    if (self.site) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleChangeNotification:) name:ContentsChangedNotification object:self.site];
        self.dirty = NO;
        NSError* error;
        if (![self.site initializeExistingSite:&error] && error) {
            NSLog(@"%@",error.localizedDescription);
            [self refreshLayoutList:NO];
        }
        self.window.title = self.site.name;
        [self.pagePostOutline expandItem:nil expandChildren:YES];
        self.currentPage = nil;
    }
    
    [self.contentTypeSelect addItemsWithTitles:@[PageContentTypeHTML,PageContentTypeTextile,PageContentTypeMarkdown]];
    
    [NSTimer scheduledTimerWithTimeInterval:10.0
                                     target:self
                                   selector:@selector(saveTimer:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)refreshLayoutList:(BOOL)withRead {
    if ((withRead && [self.site readSiteLayouts:nil]) || !withRead) {
        [self.layoutSelect removeAllItems];
        [self.layoutSelect addItemsWithTitles:self.site.layouts];
    }
}

- (void)saveTimer:(NSTimer*)timer {
    if (self.dirty) {
        [self save];
    }
}

- (void)save {
    if (self.currentPage) {
        NSError* error;
        [self.currentPage savePage:&error];
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        } else {
            self.dirty = NO;
        }
    }
}

- (void)readInterface {
    if (self.currentPage) {
        self.currentPage.title = self.nameField.stringValue;
        if (self.slugCheckbox.state == NSOffState) {
            self.currentPage.slug = self.slugField.stringValue = [self.currentPage.title slugalize];
        } else {
            self.currentPage.slug = self.slugField.stringValue;
        }
        self.currentPage.slug = self.slugField.stringValue;
        self.currentPage.content = [[NSString alloc] initWithString:self.textEditor.string];
        self.currentPage.layout = self.layoutSelect.selectedItem.title;
        self.currentPage.contentType = self.contentTypeSelect.selectedItem.title;
        if ([self.currentPage isKindOfClass:[Post class]]) {
            NSDate* newDate = self.dateSelector.dateValue;
            Post* p = (Post*)self.currentPage;
            if (![newDate isEqualToDate:p.date]) {
                p.date = newDate;
                self.dirty = YES;
            }
        }
    }
}

- (void)handleChangeNotification:(NSNotification *)notification {
    reloadMutex = YES;
    self.dirty = NO;
    id selectedItem = [self.pagePostOutline itemAtRow:self.pagePostOutline.selectedRow];
    [self.pagePostOutline reloadData];
    NSInteger itemIndex = [self.pagePostOutline rowForItem:selectedItem];
    if (itemIndex >= 0) {
        [self.pagePostOutline selectRowIndexes:[NSIndexSet indexSetWithIndex:itemIndex] byExtendingSelection:NO];
    }
    reloadMutex = NO;
}

#pragma mark - NSOutlineViewDataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        switch (index) {
            case 0:
                return @"Pages";
            case 1:
                return @"Posts";
            default:
                return nil;
        }
    } else if ([item isKindOfClass:[NSString class]] && [item isEqualToString:@"Pages"]) {
        return [self.site.pages.contents objectAtIndex:index];
    } else if ([item isKindOfClass:[NSString class]] &&[item isEqualToString:@"Posts"]) {
        return [self.site.posts objectAtIndex:index];
    } else if ([item isKindOfClass:[PageFolder class]]) {
        return [((PageFolder*)item).contents objectAtIndex:index];
    } else {
        return nil;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return ![item isKindOfClass:[Page class]];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if (item == nil) {
        return 2;
    } else if ([item isKindOfClass:[NSString class]] && [item isEqualToString:@"Pages"]) {
        return self.site.pages.contents.count;
    } else if ([item isKindOfClass:[NSString class]] &&[item isEqualToString:@"Posts"]) {
        return self.site.posts.count;
    } else if ([item isKindOfClass:[PageFolder class]]) {
        return ((PageFolder*)item).contents.count;
    } else {
        return 0;
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView* cell;
    if ([item isKindOfClass:[NSString class]]) {
        cell = [self.pagePostOutline makeViewWithIdentifier:@"HeaderCell" owner:self];
        cell.textField.stringValue = item;
    } else if ([item isKindOfClass:[Post class]]) {
        cell = [self.pagePostOutline makeViewWithIdentifier:@"PostCell" owner:self];
        cell.textField.stringValue = ((Post*)item).title;
    } else if ([item isKindOfClass:[Page class]]) {
        cell = [self.pagePostOutline makeViewWithIdentifier:@"PageCell" owner:self];
        cell.textField.stringValue = ((Page*)item).title;
    } else if ([item isKindOfClass:[PageFolder class]]) {
        cell = [self.pagePostOutline makeViewWithIdentifier:@"FolderCell" owner:self];
        cell.textField.stringValue = ((PageFolder*)item).name;
    }
    return cell;
}

#pragma mark - NSOutlineViewDelegate

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    return [item isKindOfClass:[NSString class]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item {
    return ![item isKindOfClass:[NSString class]];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification {
    if (!reloadMutex) {
        id item = [self.pagePostOutline itemAtRow: self.pagePostOutline.selectedRow];
        if ([item isKindOfClass:[Page class]]) {
            self.currentPage = item;
        } else {
            self.currentPage = nil;
        }
    }
}

#pragma mark - NSToolbarItemValidation

- (BOOL)validateToolbarItem:(NSToolbarItem *)theItem {
    if ([theItem.itemIdentifier isEqualToString:@"delete"]) {
        return self.pagePostOutline.selectedRow >= 0;
    } else {
        return YES;
    }
}

#pragma mark - Properties

- (void)setCurrentPage:(Page *)icurrentPage {
    if (currentPage != icurrentPage) {
        [self readInterface];
        [self save];
        
        currentPage = icurrentPage;
  
        [self.textEditor setEditable:currentPage != nil];
        
        [self.nameField setEnabled: currentPage != nil];
        [self.slugField setEnabled: currentPage != nil];
        [self.layoutSelect setEnabled: currentPage != nil];
        [self.dateSelector setEnabled: currentPage != nil];
        [self.contentTypeSelect setEnabled: currentPage != nil];
        
        if (currentPage) {
            self.textEditor.string = currentPage.content;
            
            self.nameField.stringValue = currentPage.title;
            NSString* standardSlug = [currentPage.title slugalize];
            if ([currentPage.slug isEqualToString:standardSlug]) {
                self.slugCheckbox.state = NSOffState;
                [self.slugField setEnabled:NO];
            } else {
                self.slugCheckbox.state = NSOnState;
                [self.slugField setEnabled:YES];
            }
            self.slugField.stringValue = currentPage.slug;
            
            [self refreshLayoutList:YES];
            [self.layoutSelect selectItemWithTitle:currentPage.layout];
            
            [self.contentTypeSelect selectItemWithTitle:currentPage.contentType];
            
            if ([currentPage isKindOfClass:[Post class]]) {
                Post* post = (Post*)currentPage;
                self.dateSelector.dateValue = post.date;
                [self.dateSelector setEnabled:YES];
            } else {
                [self.dateSelector setEnabled:NO];
            }
            
            self.window.title = [NSString stringWithFormat:@"%@: %@",self.site.name,currentPage.title];
        } else {
            self.textEditor.string = @"";
            self.window.title = self.site.name;
            self.nameField.stringValue = @"";
            self.slugField.stringValue = @"";
            [self.layoutSelect selectItemAtIndex:0];
            self.dateSelector.dateValue = [NSDate date];
            [self.contentTypeSelect selectItemWithTitle:[PageContentTypeHTML copy]];
            [self.layoutSelect selectItemWithTitle:self.site.defaultLayout];
        }
    }
}

#pragma mark - NSControlDelegate

- (void)controlTextDidChange:(NSNotification *)aNotification {
    BOOL dirty = NO;
    if (![self.nameField.stringValue isEqualToString:self.currentPage.title]) {
        self.currentPage.title = self.nameField.stringValue;
        
        if (self.slugCheckbox.state == NSOffState) {
            self.currentPage.slug = self.slugField.stringValue = [self.currentPage.title slugalize];
        }
        
        dirty = YES;
    }
    if (![self.slugField.stringValue isEqualToString:self.currentPage.slug]) {
        self.currentPage.slug = self.slugField.stringValue;
        dirty = YES;
    }
    
    self.dirty = dirty;
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification {
    if (self.dirty) {
        [self save];
    }
}

#pragma mark - NSTextViewDelegate

- (void)textDidChange:(NSNotification *)aNotification {
    if (![self.textEditor.string isEqualToString:self.currentPage.content]) {
        self.currentPage.content = [[NSString alloc] initWithString:self.textEditor.string];
        self.dirty = YES;
    }
}

#pragma mark - Actions

- (IBAction)addPage:(id)sender {
    id item = [self.pagePostOutline itemAtRow: self.pagePostOutline.selectedRow];
    PageFolder* parent;
    if ([item isKindOfClass:[PageFolder class]]) {
        parent = item;
    } else {
        parent = self.site.pages;
    }
    Page* newPage = [[Page alloc] initWithSite:self.site andParent:parent];
    newPage.title = @"New Page";
    newPage.slug = [newPage.title slugalize];
    self.currentPage = newPage;
    [self.site.pages addItem:newPage];
    NSError* error1;
    [newPage savePage:&error1];
    if (error1) {
        NSLog(@"%@",error1.localizedDescription);
    } else {
        NSError* error2;
        [self.site readSitePages:&error2];
        if (error2) {
            NSLog(@"%@",error2.localizedDescription);
        } else {
            self.currentPage = newPage;
        }
    }
}

- (IBAction)addPost:(id)sender {
    //TODO
}

- (IBAction)addFolder:(id)sender {
    //TODO
}

- (IBAction)deleteItem:(id)sender {
    //TODO
}

- (IBAction)previewSite:(id)sender {
    //TODO
}

- (IBAction)PublishSite:(id)sender {
    //TODO
}

- (IBAction)customSlugChanged:(id)sender {
    [self.slugField setEnabled:self.slugCheckbox.state == NSOnState];
    if (self.slugCheckbox.state == NSOffState) {
        self.currentPage.slug = self.slugField.stringValue = [self.currentPage.title slugalize];
        self.dirty = YES;
    }
}

- (IBAction)layoutDropdownChanged:(id)sender {
    NSString* newLayout = self.layoutSelect.selectedItem.title;
    if (![newLayout isEqualToString:self.currentPage.layout]) {
        self.currentPage.layout = newLayout;
        self.dirty = YES;
    }
}

- (IBAction)datePickerChanged:(id)sender {
    if ([self.currentPage isKindOfClass:[Post class]]) {
        NSDate* newDate = self.dateSelector.dateValue;
        Post* p = (Post*)self.currentPage;
        if (![newDate isEqualToDate:p.date]) {
            p.date = newDate;
            self.dirty = YES;
        }
    }
}

- (IBAction)contentTypeChanged:(id)sender {
    NSString* newType = self.contentTypeSelect.selectedItem.title;
    if (![newType isEqualToString:self.currentPage.contentType]) {
        self.currentPage.contentType = newType;
        self.dirty = YES;
    }
}

@end
