//
//  ModalViewController.m
//  CPK_Tool
//
//  Created by ciwei luo on 2020/6/24.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "MyViewController.h"

@interface MyViewController ()
@property (nonatomic,strong)NSViewController *mainVc;
@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.title = NSStringFromClass([self class]);

}


-(void)viewDidAppear{
    [super viewDidAppear];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowWillClose:)
                                                 name:NSWindowWillCloseNotification
                                               object:nil];
}

-(void)viewDidDisappear{
    [super viewDidDisappear];

    [self removeNSWindowWillCloseNotificationObserver];
}

-(void)dismisssViewOnViewController:(NSViewController *)vc{
    [vc dismissViewController:self];
    
    
}

-(void)showViewOnViewController:(NSViewController *)vc{
    _mainVc = vc;
    [vc presentViewControllerAsModalWindow:self];
   // [vc presentViewControllerAsSheet:self];

}
-(void)showViewAsSheetOnViewController:(NSViewController *)vc{
    _mainVc = vc;
    [vc presentViewControllerAsSheet:self];
}
- (void)windowWillClose:(NSNotification *)notification {
    [self close];
}

-(void)close{
    [_mainVc dismissViewController:self];
    
}

-(void)dealloc{
    [self removeNSWindowWillCloseNotificationObserver];
    
}

-(void)removeNSWindowWillCloseNotificationObserver{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NSWindowWillCloseNotification object:nil];
}


@end
