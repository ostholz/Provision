//
//  ProvisionsListTableViewController.m
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import "ProvisionsListTableViewController.h"

#import "HighlightableTableView.h"
#import "DragAndDroppableView.h"

#import "ProfileItem.h"
#import "ProfileManager.h"
#import "ProfileEntitlement.h"
#import "ProfileSource.h"

typedef void (^GenericAsyncCompletionBlock)(); //For nested Modals...

@interface ProvisionsListTableViewController ()

@property (strong) IBOutlet HighlightableTableView *profileListTableView;
@property (strong) IBOutlet NSArrayController *profileListArrayController;

@property (strong) IBOutlet NSOutlineView *profileSourcesTableView;

@property (strong) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSTextField *profileCountLabel;

//Data source
@property(nonatomic,strong)NSArray *provisioningProfiles;
@property(nonatomic,strong)NSArray *profileSources;

@property(nonatomic,strong)NSDateFormatter *dateFormatter;

@property(nonatomic,strong)ProfileManager *currentManager;
@end

@implementation ProvisionsListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    
    ProfileManager *localManager = [[ProfileManager alloc] initWithProfileSource:[[ProfileSource alloc] initWithDirectory:@"~/Library/MobileDevice/Provisioning Profiles" name:[NSString stringWithFormat:@"%@'s Profiles", NSUserName()]]];
    ProfileManager *xcodeManager = [[ProfileManager alloc] initWithProfileSource:[[ProfileSource alloc] initWithDirectory:@"/Library/Developer/XcodeServer/ProvisioningProfiles" name:@"Xcode Server"]];
    
    self.profileSources = @[@"PROFILES",localManager,xcodeManager];
    
    self.currentManager = localManager;
    
    [self.profileSourcesTableView expandItem:nil expandChildren:YES];
    
    [self.profileListTableView setDoubleAction:@selector(profilesTableViewDoubleClicked:)];
    
    [self.profileListTableView deselectAll:nil];
}

-(void)setCurrentManager:(ProfileManager *)currentManager
{
    _currentManager = currentManager;
    
    self.provisioningProfiles = [currentManager getProfileItems];
    [self.profileListTableView deselectAll:nil];
    
    self.profileCountLabel.stringValue = self.provisioningProfiles.count == 1 ? @"1 Profile" : [NSString stringWithFormat:@"%ld Profiles", (long)self.provisioningProfiles.count];
}

-(void)setProfileSources:(NSArray *)profileSources
{
    _profileSources = profileSources;
    
    [self.profileSourcesTableView reloadData];
}

//-(void)setProvisioningProfiles:(NSArray *)provisioningProfiles
//{
//    _provisioningProfiles = provisioningProfiles;
//
//    [self updateSearchFilters];
//}

//- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell1 forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
//{
//    ProfileItem *currentItem = self.currentlyDisplayedProfiles[row];
//
//    if ([[NSDate date] compare:currentItem.expirationDate] == NSOrderedDescending)
//    {
//        [cell1 setBackgroundColor:[NSColor colorWithRed:255.0/255.0 green:184.0/255.0 blue:184.0/255.0 alpha:1.0]];
//    }
//    else
//    {
//        [cell1 setBackgroundColor:[NSColor clearColor]];
//    }
//}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    NSTableCellView *view = nil;
    
    if ([item isKindOfClass:[NSString class]]) {
        view = [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
        view.textField.stringValue = (NSString*)item;
    } else {
        view = [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
        
        ProfileSource *source = [item profileSource];
        
        view.textField.stringValue = source.name;
    }
    return view;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[NSString class]]) {
        return NO;
    }else {
        return NO;
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    
    if (item == nil) { //item is nil when the outline view wants to inquire for root level items
        return self.profileSources.count;
    }
    //
    //    if ([item isKindOfClass:[NSString class]]) {
    //        return self.profileSources.count-1;
    //    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    
    if (item == nil) { //item is nil when the outline view wants to inquire for root level items
        return [self.profileSources objectAtIndex:index];
    }
    
    //    if ([item isKindOfClass:[NSString class]]) {
    //        return [self.profileSources objectAtIndex:index];
    //    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)theColumn byItem:(id)item
{
    
    if ([item isKindOfClass:[NSString class]]) {
        return item;
    }
    else
    {
        ProfileSource *source = [item profileSource];
        
        return source.name;
    }
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if ([item isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    return YES;
}

-(void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    //Get selection
    ProfileManager *manager = self.profileSources[self.profileSourcesTableView.selectedRow];
    self.currentManager = manager;
}

-(void)profilesTableViewDoubleClicked:(id)sender
{
    if ([self.profileListTableView clickedRow] < [self.profileListArrayController.arrangedObjects count])
    {
        ProfileItem *currentProfile = [self.profileListArrayController.arrangedObjects objectAtIndex:[self.profileListTableView clickedRow]];
        
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[[NSURL fileURLWithPath:currentProfile.filePath]]];
    }
}

#pragma mark Mass editing
-(IBAction)removeExpiredProfilesInScope:(id)sender
{
    [self.profileListTableView deselectAll:nil];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    if (self.searchField.stringValue.length == 0) {
        [alert setMessageText:[NSString stringWithFormat:@"Delete all expired profiles in '%@'?", self.currentManager.profileSource.name]];
    }
    else
    {
        [alert setMessageText:[NSString stringWithFormat:@"Delete all expired profiles in '%@', matching the search query '%@'?", self.currentManager.profileSource.name,self.searchField.stringValue]];
    }
    
    [alert setInformativeText:@"Deleted profiles cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == 1000) {
            NSArray *selectedProfiles = self.profileListArrayController.arrangedObjects;
            
            NSDate *now = [NSDate date];
            for (ProfileItem *currentItem in selectedProfiles) {
                
                if ([now compare:currentItem.expirationDate] == NSOrderedDescending) {
                    //Needs to be deleted.
                    NSError *deleteError;
                    [[NSFileManager defaultManager] removeItemAtPath:currentItem.filePath error:&deleteError];
                    
                    if (deleteError) {
                        NSLog(@"%@",deleteError);
                    }
                }
            }
            
            self.currentManager = self.currentManager;
        }
    }];
}

-(IBAction)deleteSelectedProfiles:(id)sender
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete selected profiles?"];
    
    [alert setInformativeText:@"Deleted profiles cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == 1000) {
            NSArray *selectedProfiles = [self.profileListArrayController.arrangedObjects objectsAtIndexes:self.profileListTableView.selectedRowIndexes];
            
            for (ProfileItem *currentItem in selectedProfiles) {
                
                //Needs to be deleted.
                NSError *deleteError;
                [[NSFileManager defaultManager] removeItemAtPath:currentItem.filePath error:&deleteError];
                
                if (deleteError) {
                    NSLog(@"%@",deleteError);
                }
            }
            
            self.currentManager = self.currentManager;
        }
    }];
}

-(IBAction)deleteDuplicateProfilesInScope:(id)sender
{
    [self.profileListTableView deselectAll:nil];
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Cancel"];
    if (self.searchField.stringValue.length == 0) {
        [alert setMessageText:[NSString stringWithFormat:@"Delete duplicate profiles in '%@'?", self.currentManager.profileSource.name]];
    }
    else
    {
        [alert setMessageText:[NSString stringWithFormat:@"Delete duplicate profiles in '%@', matching the search query '%@'?", self.currentManager.profileSource.name,self.searchField.stringValue]];
    }
    
    [alert setInformativeText:@"Deleted profiles cannot be restored. We'll keep your most recent one for each configuration."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == 1000) {
            NSArray *selectedProfiles = self.profileListArrayController.arrangedObjects;
            
            for (ProfileItem *currentItem in selectedProfiles) {
                
                if (currentItem.isOlderDuplicateProfile) {
                    //Needs to be deleted.
                    NSError *deleteError;
                    [[NSFileManager defaultManager] removeItemAtPath:currentItem.filePath error:&deleteError];
                    
                    if (deleteError) {
                        NSLog(@"%@",deleteError);
                    }
                }
            }
            
            self.currentManager = self.currentManager;
        }
    }];
}

-(BOOL)validateToolbarItem:(NSToolbarItem *)theItem
{
    if ([theItem.itemIdentifier isEqualToString:@"deleteexpired"]) {
        return YES;
    }
    
    if ([theItem.itemIdentifier isEqualToString:@"deleteselected"]) {
        if (self.profileListTableView.selectedRowIndexes.count > 0) {
            return YES;
        }
        
        return NO;
    }
    
    return YES;
}

-(IBAction)refreshCurrentProfileList:(id)sender
{
    self.currentManager = self.currentManager;
}

-(void)draggableView:(HighlightableTableView *)view didReceiveFiles:(NSArray *)files
{
    //Awesome! Let's import some files.
    [self importFilesAtPaths:files];
}

-(void)importFilesAtPaths:(NSArray*)files
{
    NSMutableArray *olderProfilesFound = [NSMutableArray array];
    NSMutableArray *newProfilesThatAreOld = [NSMutableArray array];
    NSMutableArray *filesToImport = [NSMutableArray array];
    
    
    for (NSString *currentPath in files) {
        ProfileItem *importedProfile = [[ProfileItem alloc] initWithFilePath:currentPath];
        
        if (importedProfile) {
            
            //Check for collisions and Dates
            
            BOOL foundCollisionOrNewer = NO;
            NSArray *allProfiles = [self.currentManager getProfileItems];
            
            for (ProfileItem *currentProfile in allProfiles) {
                if ([currentProfile isEquivalentToProfile:importedProfile]) {
                    //Oh, no! We have one of these. Let's see which one is newer.
                    foundCollisionOrNewer = YES;
                    
                    if ([currentProfile.expirationDate compare:importedProfile.expirationDate] == NSOrderedAscending) {
                        [olderProfilesFound addObject:currentPath];
                    }
                    else if ([currentProfile.expirationDate compare:importedProfile.expirationDate] == NSOrderedDescending)
                    {
                        [newProfilesThatAreOld addObject:currentPath];
                    } else
                    {
                        //These are equal...we won't add them.
                    }
                }
            }
            
            if (!foundCollisionOrNewer) {
                [filesToImport addObject:currentPath];
            }
        }
    }
    
    //Import everything that's cleared as 'new'
    for (NSString *currentPath in filesToImport) {
        [[NSFileManager defaultManager] copyItemAtPath:currentPath toPath:[[self.currentManager.profileSource.path stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"mobileprovision"] error:nil];
    }
    
    self.currentManager = self.currentManager;
    
    //Now to deal with the others.
    if (olderProfilesFound.count != 0) {
        //Ask if they want us to delete the older ones.
        [self promptToDeleteOlderVersionsOfProfilesAtPaths:olderProfilesFound withCompletion:^{
            
            if (newProfilesThatAreOld.count > 0) {
                [self promptToImportOutdatedProfilesAtPathes:newProfilesThatAreOld withCompletion:^{
                    if (olderProfilesFound.count + newProfilesThatAreOld.count + filesToImport.count != files.count) {
                        //Looks like we should prompt a notice that some weren't imported.
                        [self alertThatSomeDuplicatesWereNotImported];
                    }
                }];
            }
        }];
    }else if (newProfilesThatAreOld.count > 0) {
        [self promptToImportOutdatedProfilesAtPathes:newProfilesThatAreOld withCompletion:^{
            if (olderProfilesFound.count + newProfilesThatAreOld.count + filesToImport.count != files.count) {
                //Looks like we should prompt a notice that some weren't imported.
                [self alertThatSomeDuplicatesWereNotImported];
            }
        }];
    } else
    {
        if (olderProfilesFound.count + newProfilesThatAreOld.count + filesToImport.count != files.count) {
            //Looks like we should prompt a notice that some weren't imported.
            [self alertThatSomeDuplicatesWereNotImported];
        }
    }
}

-(void)promptToDeleteOlderVersionsOfProfilesAtPaths:(NSArray*)profiles withCompletion:(GenericAsyncCompletionBlock)completion
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Delete"];
    [alert addButtonWithTitle:@"Keep"];
    [alert setMessageText:[NSString stringWithFormat:@"We found older versions of 1 or more of your profiles in '%@'. Would you like us to delete them on import?", self.currentManager.profileSource.name]];
    
    [alert setInformativeText:@"Deleted profiles cannot be restored. We'll keep your most recent one for each configuration."];
    [alert setAlertStyle:NSWarningAlertStyle];
    
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == 1000) {
            //Delete all the profiles that will be duplicates first.
            for (NSString *currentPath in profiles) {
                ProfileItem *importedProfile = [[ProfileItem alloc] initWithFilePath:currentPath];
                
                if (importedProfile) {
                    
                    //Check for collisions and dates
                    NSArray *allProfiles = [self.currentManager getProfileItems];
                    
                    for (ProfileItem *currentProfile in allProfiles) {
                        if ([currentProfile isEquivalentToProfile:importedProfile]) {
                            if ([currentProfile.expirationDate compare:importedProfile.expirationDate] == NSOrderedAscending) {
                                //Delete this one
                                [[NSFileManager defaultManager] removeItemAtPath:currentProfile.filePath error:nil];
                            }
                        }
                    }
                }
            }
            
        }
        
        for (NSString *currentPath in profiles) {
            [[NSFileManager defaultManager] copyItemAtPath:currentPath toPath:[[self.currentManager.profileSource.path stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"mobileprovision"] error:nil];
        }
        
        if (completion) {
            completion();
        }
        
        self.currentManager = self.currentManager;
    }];
}

-(void)promptToImportOutdatedProfilesAtPathes:(NSArray*)profiles withCompletion:(GenericAsyncCompletionBlock)completion
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    [alert setMessageText:[NSString stringWithFormat:@"We found newer versions of 1 or more of your profiles already in '%@'. Do you still want to import the older versions?", self.currentManager.profileSource.name]];
    
    [alert setAlertStyle:NSWarningAlertStyle];
    
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
        if (returnCode == 1000) {
            for (NSString *currentPath in profiles) {
                NSError *error;
                [[NSFileManager defaultManager] copyItemAtPath:currentPath toPath:[[self.currentManager.profileSource.path stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"mobileprovision"] error:&error];
                
                NSLog(@"%@",error);
            }
        }
        
        if (completion) {
            completion();
        }
        
        self.currentManager = self.currentManager;
    }];
}

-(void)alertThatSomeDuplicatesWereNotImported
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:[NSString stringWithFormat:@"We found 1 or more profiles in '%@' that were already present. We skipped importing them.", self.currentManager.profileSource.name]];
    
    [alert setAlertStyle:NSInformationalAlertStyle];
    
    [alert beginSheetModalForWindow:self.view.window completionHandler:nil];
}

-(void)draggableView:(DragAndDroppableView*)view shouldHighlight:(BOOL)highlight
{
    self.profileListTableView.highlighted = highlight;
}

-(void)tableViewRequestsDeleteForCurrentSelection:(NSTableView*)tableView
{
    [self deleteSelectedProfiles:nil];
}

@end
