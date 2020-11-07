//
//  reportSettingCfg.m
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "reportSettingCfg.h"

@interface reportSettingCfg ()

@end

@implementation reportSettingCfg

- (void)windowDidLoad {
    [super windowDidLoad];
    [_settingCfgWin setLevel:kCGFloatingWindowLevel];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)btnOK:(id)sender
{
    [NSApp stopModalWithCode:NSModalResponseOK];
    [[sender window] orderOut:self];
    
}
- (IBAction)btnCancel:(id)sender
{
    [NSApp stopModalWithCode:NSModalResponseCancel];
    [[sender window] orderOut:self];
}

@end
