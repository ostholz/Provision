//
//  DragAndDroppableView.h
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DragAndDroppableView;

@protocol DragAndDroppableViewReceiver <NSObject>

-(void)draggableView:(DragAndDroppableView*)view didReceiveFiles:(NSArray*)files;
-(void)draggableView:(DragAndDroppableView*)view shouldHighlight:(BOOL)highlight;

@end

@interface DragAndDroppableView : NSView

@property(nonatomic,weak)IBOutlet id <DragAndDroppableViewReceiver> dragReceiver;
@property(nonatomic,assign,readonly)BOOL highlighted;
@end