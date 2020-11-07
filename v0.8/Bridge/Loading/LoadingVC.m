//
//  LoadingVC.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/5.
//  Copyright © 2020 Suncode. All rights reserved.
//

#import "LoadingVC.h"
//#import "PresentCustomAnimator.h"
@interface LoadingVC ()
@property (weak) IBOutlet NSProgressIndicator *loadingView;
@property (weak) IBOutlet NSTextField *showingLabel;

@end

@implementation LoadingVC

+(LoadingVC *)loadingVC{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"CWGeneralManager" ofType:@"framework"];
    NSBundle *SDKBundle = [NSBundle bundleWithPath:path];

   // LoadingVC *view = [SDKBundle loadNibNamed: @"LoadingVC" owner: nil options: nil].firstObject;

    LoadingVC *vc = [[LoadingVC alloc]initWithNibName:@"LoadingVC" bundle:SDKBundle];
//    [vc.view addSubview: view];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _showingText = @"Loading Data.Please Wait...";
    _isShowing =YES;

}
-(void)viewWillDisappear{
    [super viewWillDisappear];
    // Do view setup here.
    [self.loadingView stopAnimation:self];
    _isShowing = NO;
}
-(void)viewWillAppear{
    [super viewWillAppear];
    // Do view setup here.
   self.showingLabel.stringValue = _showingText;
    [self.loadingView startAnimation:self];
    _isShowing= YES;

}



-(void)setShowingText:(NSString *)showingText{
    _showingText = showingText;
    if ([showingText.lowercaseString containsString:@"report"]) {
        _showingText = @"Generating Report...";
    }else if([showingText.lowercaseString containsString:@"plot"]){
        _showingText = @"Generating Report...";
    }else if([showingText.lowercaseString containsString:@"csv"]){
        _showingText = @"Loading Data.Please Wait...";
    }
    else if([showingText.lowercaseString containsString:@"script"]){
        _showingText = @"Loading Data.Please Wait...";
    }
    
    else{//script
       _showingText = @"Loading Data.Please Wait...";
    }

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.showingLabel.stringValue = _showingText;
            
        });
    });
}




@end
