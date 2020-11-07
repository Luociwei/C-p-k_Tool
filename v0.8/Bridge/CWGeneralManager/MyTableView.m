//
//  MyTableView.m
//  CPK_Tool
//
//  Created by ciwei luo on 2020/6/19.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "MyTableView.h"

@implementation MyTableView


-(void)mouseDown:(NSEvent *)theEvent {
    
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    
    [super mouseDown:theEvent];

    if(clickedRow != -1){
        if (self.extendedDelegate && [self.extendedDelegate respondsToSelector:@selector(tableView:didClickedRow:location:)]) {
            [self.extendedDelegate tableView:self didClickedRow:clickedRow location:localLocation];
        }
        

        
    }
}

//
//
//- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
//
//    return YES;
//}

- (void)keyUp:(NSEvent *)theEvent {

//    NSString *str = theEvent.characters;
//
//    NSString *strIg = theEvent.charactersIgnoringModifiers;
//
//    NSInteger code = theEvent.keyCode;

    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}


-(void)moveUp:(id)sender {
    if (self.extendedDelegate && [self.extendedDelegate respondsToSelector:@selector(tableViewKeyMove:)]) {
        [self.extendedDelegate tableViewKeyMove:self];
    }
    
//    NSLog(@"moveUp");
}
-(void)moveDown:(id)sender {
//    NSLog(@"moveDown");
    if (self.extendedDelegate && [self.extendedDelegate respondsToSelector:@selector(tableViewKeyMove:)]) {
        [self.extendedDelegate tableViewKeyMove:self];
    }
}
@end
