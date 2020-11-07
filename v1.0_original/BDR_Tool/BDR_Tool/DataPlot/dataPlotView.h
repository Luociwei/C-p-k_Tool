//
//  dataPlotView.h
//  CPK_Test
//
//  Created by RyanGao on 2020/6/25.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface dataPlotView : NSViewController<NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSTableView *colorByTableView;
@property (weak) IBOutlet NSComboBox *colorByBox;
- (IBAction)selectColorByBoxAction:(id)sender;
@property (weak) IBOutlet NSTableView *colorByTableView2;
@property (weak) IBOutlet NSComboBox *colorByBox2;
- (IBAction)selectColorByBoxAction2:(id)sender;


@property (weak) IBOutlet NSImageView *cpkImageView;
@property (weak) IBOutlet NSImageView *correlationImageView;

@property (weak) IBOutlet NSSegmentedControl *retestSegment;
- (IBAction)clickRetestSegmentAction:(id)sender;

@property (weak) IBOutlet NSSegmentedControl *removeFailSegment;
- (IBAction)clickRemoveFailSegmentAction:(id)sender;
- (IBAction)btnShowData:(id)sender;

@property (weak) IBOutlet NSTextField *txtBins;
- (IBAction)setTxtBinsValue:(id)sender;

- (IBAction)btnSelectX:(id)sender;
- (IBAction)btnSelectY:(id)sender;

- (IBAction)btnReport:(id)sender;  //keynote
- (IBAction)btnReportExcel:(id)sender;
@property (strong) IBOutlet NSView *customerMainView;

@property (weak) IBOutlet NSView *customerViewL;
@property (weak) IBOutlet NSSlider *sliderL;
- (IBAction)sliderActionL:(id)sender;
@property (weak) IBOutlet NSView *customerViewR;
@property (weak) IBOutlet NSSlider *sliderR;
- (IBAction)sliderActionR:(id)sender;

@end

NS_ASSUME_NONNULL_END
