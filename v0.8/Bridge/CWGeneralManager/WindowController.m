//
//  WindowController.m
//  SC_CPK
//
//  Created by ciwei luo on 2020/4/5.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "WindowController.h"

@interface WindowController ()

@end

@implementation WindowController

-(void)cw_addViewController:(NSViewController *)testVC{
    self.contentViewController = testVC;
}

-(void)cw_addViewController:(NSViewController *)testVC logVC:(NSViewController *)logVC{
    if (logVC) {
        NSSplitViewController *splitVC = [[NSSplitViewController alloc]init];
        [splitVC.splitView setVertical:NO];
        splitVC.splitView .dividerStyle=3;
        
        NSSplitViewItem *item1 = [NSSplitViewItem splitViewItemWithViewController:testVC];
        
        NSSplitViewItem *item2 = [NSSplitViewItem splitViewItemWithViewController:logVC];
        [item2 setCollapsed:YES];
        [splitVC addSplitViewItem:item1];
        [splitVC addSplitViewItem:item2];
        
        self.contentViewController = splitVC;
    }else{
        self.contentViewController = testVC;
    }
    
}

-(void)cw_addViewControllers:(NSArray <NSViewController *> *)testVCs{
    [self cw_addViewControllers:testVCs logVC:nil];
    
}

-(void)cw_addViewControllers:(NSArray <NSViewController *> *)testVCs logVC:(NSViewController *)logVC{
    if (logVC != nil) {
        NSSplitViewController *splitVC = [[NSSplitViewController alloc]init];
        [splitVC.splitView setVertical:NO];
        splitVC.splitView .dividerStyle=3;
        if (!testVCs.count) {
            return;
        }
        
        NSTabViewController *tabVC=nil;
        if (testVCs.count==1) {
            self.contentViewController = testVCs[0];
            return;
        }else{
            tabVC = [[NSTabViewController alloc]init];
            for (int i =0; i<testVCs.count; i++) {
                NSViewController *vc = testVCs[i];
                [tabVC addChildViewController:vc];
            }
            
        }
        NSSplitViewItem *item1 = [NSSplitViewItem splitViewItemWithViewController:tabVC];
        
        NSSplitViewItem *item2 = [NSSplitViewItem splitViewItemWithViewController:logVC];
        [splitVC addSplitViewItem:item1];
        [splitVC addSplitViewItem:item2];
        
        self.contentViewController = splitVC;
        
    }else{
        if (!testVCs.count) {
            return;
        }
        if (testVCs.count==1) {
            self.contentViewController = testVCs[0];
        }else{
            NSTabViewController *tabVC = [[NSTabViewController alloc]init];
            for (int i =0; i<testVCs.count; i++) {
                NSViewController *vc = testVCs[i];
                [tabVC addChildViewController:vc];
            }
            self.contentViewController = tabVC;
        }
    }
    
    
    
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
