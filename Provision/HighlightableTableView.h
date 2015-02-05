//
//  DragAndDroppableProfileVIew.h
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class HighlightableTableView;

@protocol HighlightedTableViewDeletionDelegate <NSObject>

-(void)tableViewRequestsDeleteForCurrentSelection:(NSTableView*)tableView;

@end


@interface HighlightableTableView : NSTableView

@property(nonatomic,assign)BOOL highlighted;

@property(nonatomic,weak)IBOutlet id<HighlightedTableViewDeletionDelegate> deletionDelegate;
@end
