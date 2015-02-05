//
//  DragAndDroppableView.m
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import "DragAndDroppableView.h"

@implementation DragAndDroppableView

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    if (self = [super initWithCoder:coder]) {
        [self registerForDraggedTypes:
         [NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
    }
    
    return self;
}

- (NSDragOperation)draggingEntered:(id )sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
        == NSDragOperationGeneric) {
        
        NSPasteboard *pasteboard = [sender draggingPasteboard];
        
        NSArray *filenames = [pasteboard propertyListForType:@"NSFilenamesPboardType"];
        
        BOOL containsMobileProvision = NO;
        
        for (NSString *file in filenames) {
            if ([[file pathExtension].lowercaseString isEqualToString:@"mobileprovision"]) {
                containsMobileProvision = YES;
            }
        }

        if (containsMobileProvision) {
            _highlighted = YES;
            
            if ([self.dragReceiver respondsToSelector:@selector(draggableView:shouldHighlight:)]) {
                [self.dragReceiver draggableView:self shouldHighlight:self.highlighted];
            }
            
            [[NSCursor dragCopyCursor] set];
            [self setNeedsDisplay:YES];
            
            return NSDragOperationCopy;
        }
        else
        {
            return NSDragOperationNone;
        }
    }
    return NSDragOperationNone;
}

-(void)draggingExited:(id<NSDraggingInfo>)sender
{
    _highlighted = NO;
    if ([self.dragReceiver respondsToSelector:@selector(draggableView:shouldHighlight:)]) {
        [self.dragReceiver draggableView:self shouldHighlight:self.highlighted];
    }
    
    [[NSCursor arrowCursor] set];
    [self setNeedsDisplay:YES];
}


- (BOOL)prepareForDragOperation:(id )sender {
    return YES;
}

- (BOOL)performDragOperation:(id )sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    
    NSArray *filenames = [pasteboard propertyListForType:@"NSFilenamesPboardType"];
    
    if ([self.dragReceiver respondsToSelector:@selector(draggableView:didReceiveFiles:)]) {
        [self.dragReceiver draggableView:self didReceiveFiles:filenames];
    }
    return YES;
}


- (void)concludeDragOperation:(id )sender {
    
    _highlighted = NO;
    
    if ([self.dragReceiver respondsToSelector:@selector(draggableView:shouldHighlight:)]) {
        [self.dragReceiver draggableView:self shouldHighlight:self.highlighted];
    }
    
    [[NSCursor arrowCursor] set];
    [self setNeedsDisplay:YES];
}

@end
