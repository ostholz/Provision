//
//  DragAndDroppableProfileVIew.m
//  Provision
//
//  Created by Brendan Lee on 2/4/15.
//  Copyright (c) 2015 52inc. All rights reserved.
//

#import "HighlightableTableView.h"


@interface HighlightableTableView ()

@end

@implementation HighlightableTableView

@synthesize highlighted = _highlighted;

-(void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (self.highlighted) {
        //highlight by overlaying a gray border
        [[[NSColor blueColor] colorWithAlphaComponent:0.3] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: dirtyRect];
    }
    
}

-(void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    
    [self setNeedsDisplay:YES];
}

-(void)keyDown:(NSEvent *)theEvent
{
    if (theEvent.keyCode == 51) {
        if ([self.deletionDelegate respondsToSelector:@selector(tableViewRequestsDeleteForCurrentSelection:)]) {
            [self.deletionDelegate tableViewRequestsDeleteForCurrentSelection:self];
        }
    }
}

@end
