//
//  ProvisionsListTableViewController.h
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragAndDroppableView.h"
#import "HighlightableTableView.h"

@interface ProvisionsListTableViewController : NSViewController<NSTableViewDataSource,NSOutlineViewDataSource,NSOutlineViewDelegate,DragAndDroppableViewReceiver,HighlightedTableViewDeletionDelegate>

-(void)importFilesAtPaths:(NSArray*)files;

@end
