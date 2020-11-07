//
//  csvListController.m
//  BDR_Tool
//
//  Created by RyanGao on 2020/7/5.
//  Copyright © 2020 RyanGao. All rights reserved.
//

#import "csvListController.h"
#import "defineHeader.h"


extern NSMutableDictionary *m_configDictionary;

@interface csvListController ()
{
    NSString *desktopPath;
}



@end

@implementation csvListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self fillTestData];
    
    [self.outlineView expandItem:nil expandChildren:YES];
   
}

//- (void)setDataSource
//{
//    [_outlineView setDataSource:(id)self];
//}
//
//- (void)setDelegate
//{
//    [_outlineView setDelegate:self];
//}

#pragma mark path load methods

- (void)fillTestData
{
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:@"csvListFile" ofType:@"plist"];
    //NSString *filePath = @"/Users/RyanGao/Desktop/CPK_Log/temp/22222.plist";
    
    desktopPath = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/CPK_Log/temp/.loadScript.plist",desktopPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filePath])
    {
        NSDictionary *dic0 =nil;
        NSArray *array = [[NSArray alloc] initWithObjects:dic0,nil];
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Data",@"name",array,@"items", nil];
        NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:@"Test Script",@"name",array,@"items", nil];
        NSArray *arr = [[NSArray alloc] initWithObjects:dict1,dict2,nil];
        BOOL flag1 = [arr writeToFile:filePath atomically:YES];
              if (flag1) {
                  NSLog(@"plist文件写入成功");
              }else{
                  NSLog(@"plist 文件写入失败");
              }
    }
    if (filePath)
    {
        self.feeds = [Feed pathList:filePath];
        NSLog(@"path: %@", self.feeds);
        [self.outlineView reloadData];
    }

}

#pragma mark - Actions

- (IBAction)doubleClickedItem:(NSOutlineView *)sender
{
    Feed *item = [sender itemAtRow:[sender clickedRow]];
    if ([item isKindOfClass:[Feed class]]) {
        if ([sender isItemExpanded:item]) {
            [sender collapseItem:item];
        } else {
            [sender expandItem:item];
        }
    }
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if ([item isKindOfClass:[Feed class]]) {
        NSLog(@"feed.children.count");
        Feed *feed = (Feed *)item;
        return feed.children.count;
    } else {
        NSLog(@"self.feeds.count");
        return self.feeds.count;
    }
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    Feed *feed = (Feed *)item;
    if (feed) {
        return feed.children[index];
    } else {
        return self.feeds[index];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[Feed class]]) {
        Feed *feed = (Feed *)item;
        return feed.children.count > 0;
    } else {
        return NO;
    }
}


#pragma mark - NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSTableCellView *view;
    
    if ([item isKindOfClass:[Feed class]])
    {
        Feed *feed = (Feed *)item;
//        if ([tableColumn.identifier isEqualToString:@"index"])
//        {
//            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"IndexCell" owner:self];
//            NSTextField *textField = view.textField;
//            if (textField) {
//                textField.stringValue = feed.name;
//                [textField sizeToFit];
//            }
//        }
         if ([tableColumn.identifier isEqualToString:@"filepath"])
        {
            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"FilePathCell" owner:self];
            NSTextField *textField = view.textField;
            if (textField) {
                textField.stringValue = feed.name;
                [textField sizeToFit];
            }
        }
        else if ([tableColumn.identifier isEqualToString:@"choosepath"])
                {
                    view = [outlineView makeViewWithIdentifier:@"choosepath" owner:self];
                    NSButton *cellButton = (NSButton*)view;
        //                 NSString *itemName = [self getItemName:item];
        //                 [cellButton setTitle:itemName];
//                    cellButton.tag = row;
//                    cellButton.target = self;
                         [cellButton setAction:@selector(btnChoose:)];
                         
                }
       
    }
    else if ([item isKindOfClass:[FeedItem class]])
    {
        FeedItem *feedItem = (FeedItem *)item;
//        if ([tableColumn.identifier isEqualToString:@"index"]) {
//            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"IndexCell" owner:self];
//            NSTextField *textField = view.textField;
//            if (textField) {
//                textField.stringValue = feedItem.indexPath;
//                [textField sizeToFit];
//            }
//        }
     if ([tableColumn.identifier isEqualToString:@"filepath"])
        {
            view = (NSTableCellView *)[outlineView makeViewWithIdentifier:@"FilePathItemCell" owner:self];
            NSTextField *textField = view.textField;
            if (textField) {
                textField.stringValue = feedItem.pathFile;
                [textField sizeToFit];
            }
        }
         else if ([tableColumn.identifier isEqualToString:@"checkbox"])
        {
            view = [outlineView makeViewWithIdentifier:@"checkbox" owner:self];
            NSButton *cellButton = (NSButton*)view;
            [cellButton setIntValue:feedItem.flag];
//                 NSString *itemName = [self getItemName:item];
//                 [cellButton setTitle:itemName];
                 [cellButton setAction:@selector(itemChecked:)];
                 
        }

    }
    return view;
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
//    if (![notification.object isKindOfClass:[NSOutlineView class]]) {
//        return;
//    }
//    NSOutlineView *outlineView = (NSOutlineView *)notification.object;
//    NSInteger selectedIndex = outlineView.selectedRow;
//    FeedItem *feedItem = [outlineView itemAtRow:selectedIndex];
//    if (![feedItem isKindOfClass:[FeedItem class]]) {
//        return;
//    }
//    if (feedItem)
//    {
//        NSURL *url = [NSURL URLWithString:feedItem.url];
//        if (url) {
//            [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
//        }
//    }
}

#pragma mark - Keyboard Handling

- (void)keyDown:(NSEvent *)event
{
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (void)deleteBackward:(id)sender
{
    NSLog(@"delete key detected");
    
    NSUInteger selectedRow = self.outlineView.selectedRow;
    if (selectedRow == -1) {
        return;
    }
    
    [self.outlineView beginUpdates];
    
    id item = [self.outlineView itemAtRow:selectedRow];
    if ([item isKindOfClass:[Feed class]]) {
//        Feed *feed = (Feed *)item;
//        NSUInteger index = [self.feeds indexOfObjectPassingTest:^BOOL(Feed * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            return [feed.name isEqualToString:obj.name];
//        }];
//        if (index != NSNotFound) {
//            [self.feeds removeObjectAtIndex:index];
//            [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:selectedRow] inParent:nil withAnimation:NSTableViewAnimationSlideLeft];
//        }
    } else if ([item isKindOfClass:[FeedItem class]])
    {
        FeedItem *feedItem = (FeedItem *)item;
        for (Feed *feed in self.feeds) {
            NSUInteger index = [feed.children indexOfObjectPassingTest:^BOOL(FeedItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
            {
                return [feedItem.pathFile isEqualToString:obj.pathFile];
                
            }];
            if (index != NSNotFound)
            {
                [feed.children removeObjectAtIndex:index];
                NSLog(@"=======remove: %zd,  %@  ,  %@",index,feed.name,feed.children);
                [self.outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:index] inParent:feed withAnimation:NSTableViewAnimationSlideLeft];
            }
        }
        
        NSString *name1 = self.feeds[0].name;
        NSArray *arr1 = self.feeds[0].children;
        NSMutableArray *arrM1 = [NSMutableArray array];
        for (int i=0; i<[arr1 count]; i++)
        {
            NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr1[i]] componentsSeparatedByString:@","];
            int check = [arrsub[0] intValue];
            NSString *filePath = arrsub[1];
            NSDictionary *dicitem =[NSDictionary dictionaryWithObjectsAndKeys:filePath,@"file_path",[NSNumber numberWithInt:check],@"check",nil];
            [arrM1 addObject:dicitem];
        }
        NSDictionary *dict1 = [NSDictionary dictionaryWithObjectsAndKeys:name1,@"name",arrM1,@"items", nil];
        
        
        NSString *name2 = self.feeds[1].name;
        NSArray *arr2 = self.feeds[1].children;
        NSMutableArray *arrM2 = [NSMutableArray array];
        for (int i=0; i<[arr2 count]; i++)
        {
            NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr2[i]] componentsSeparatedByString:@","];
            int check = [arrsub[0] intValue];
            NSString *filePath = arrsub[1];
            NSDictionary *dicitem =[NSDictionary dictionaryWithObjectsAndKeys:filePath,@"file_path",[NSNumber numberWithInt:check],@"check",nil];
            [arrM2 addObject:dicitem];
        }
        NSDictionary *dict2 = [NSDictionary dictionaryWithObjectsAndKeys:name2,@"name",arrM2,@"items", nil];
        
        NSArray *arr = [NSArray arrayWithObjects:dict1,dict2, nil];
        NSString *filePath = [NSString stringWithFormat:@"%@/CPK_Log/temp/.loadScript.plist",desktopPath];
        BOOL flag1 = [arr writeToFile:filePath atomically:YES];
                   if (flag1) {
                       NSLog(@"plist文件写入成功");
                   }else{
                       NSLog(@"plist 文件写入失败");
                   }
        
        
        
       
        
//        NSArray *arr = [NSArray arrayWithObjects:dic1,dic2, nil];
        
        
    }
    
    [self.outlineView endUpdates];
}


- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item{

    return 20;

}


-(NSString *)openCSVLoadPanel
{
    NSString *csvpath =nil;
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO]; //设置多选模式
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:[NSArray arrayWithObjects:@"CSV", @"csv", @"Csv",nil]];
    //[panel setDirectoryURL:[NSURL URLWithString:desktopPath]];
    [panel runModal];
    if ([[panel URLs] count]>0)
    {
        csvpath = [[[panel URLs] objectAtIndex:0] path];
        //[self.txtScriptPath setStringValue:csvpath];
    }
//    else
//    {
//        //[self.txtScriptPath setStringValue:@"--"];
//    }
    //if (csvpath==nil || [csvpath isEqualToString:desktopPath])
//    if (csvpath==nil)
//    {
//        return nil;
//    }
    return csvpath;
}

#pragma mark Action methods



-(IBAction)btnChoose:(id)sender
{
    NSLog(@"=====button chose==");
    NSInteger checkedCellIndex = [_outlineView rowForView:sender];
    NSString *strpath = [self openCSVLoadPanel];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"csvListFile" ofType:@"plist"];
    NSString *filePath = [NSString stringWithFormat:@"%@/CPK_Log/temp/.loadScript.plist",desktopPath];
    if (strpath)
    {
        if (checkedCellIndex<1)
        {
            
            if (filePath)
            {
                [Feed addToPathWrite:filePath withAddPath:strpath with:0];

            }
        }
        else
        {
            if (filePath)
            {
                [Feed addToPathWrite:filePath withAddPath:strpath with:1];
            }
        }
        self.feeds = [Feed pathList:filePath];
        [self.outlineView reloadData];
        [self.outlineView expandItem:nil expandChildren:YES];
    }
}

- (IBAction)itemChecked:(id)sender
{
    NSButton *checkedCellButton = (NSButton*)sender;
   // NSString *checkedCellName = [checkedCellButton title];
    NSInteger checkedCellIndex = [_outlineView rowForView:sender];
    //id itemAtRow = [_outlineView itemAtRow:checkedCellIndex];
    //NSLog(@"====itemChecked>>>%@, %@",checkedCellName,itemAtRow);
   
    int state = (int)checkedCellButton.state;
    //NSLog(@"====<<>>>>%ld: %@   %zd", checkedCellIndex, checkedCellName,state);
    
    
//    self.feed
    NSArray *arr1 = self.feeds[0].children;
    NSUInteger count = [arr1 count] ;
    NSString *filePath = [NSString stringWithFormat:@"%@/CPK_Log/temp/.loadScript.plist",desktopPath];
    
    if (checkedCellIndex<=count)
    {
        int line = (int)checkedCellIndex-1;
        //self.feeds[0].children[line].flag = state;
        [Feed addToItemClick:filePath withLine:line ItemClick:state with:0];
    }
    else
    {
        int line = (int)(checkedCellIndex-count -2);
        [Feed addToItemClick:filePath withLine:line ItemClick:state with:1];
        //self.feeds[1].children[checkedCellIndex-count -2].flag = state;
    }

//    [self.outlineView reloadData];
    
    self.feeds = [Feed pathList:filePath];
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];

  
}



- (IBAction)btLoadScript:(id)sender
{
    [self.outlineView reloadData];
    NSString *dataCsv = nil;
    NSArray *arr1 = self.feeds[0].children;
    for (int i=0; i<[arr1 count]; i++)
    {
        NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr1[i]] componentsSeparatedByString:@","];
        int check = self.feeds[0].children[i].flag;
        if (check == 1)
        {
            dataCsv = arrsub[1];
            break;
        }
    }
    
    
    NSString *scriptCsv = nil;
    NSArray *arr2 = self.feeds[1].children;
    for (int i=0; i<[arr2 count]; i++)
    {
        NSArray * arrsub = [[NSString stringWithFormat:@"%@",arr2[i]] componentsSeparatedByString:@","];
//        int check = [arrsub[0] intValue];
        int check = self.feeds[1].children[i].flag;
        if (check == 1)
        {
            scriptCsv =arrsub[1];
            break;
        }
    }
    NSLog(@"======dataCsv: %@,  scriptCsv:%@",dataCsv,scriptCsv);
    [m_configDictionary setValue:dataCsv forKey:Load_Csv_Path];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:dataCsv,@"data_csv",scriptCsv,@"script_csv", nil];
    //NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:xy] forKey:selectXY];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationToLoadCsv object:nil userInfo:dic];

    //[m_configDictionary setValue:csvPath forKey:Load_Csv_Path];
    //kNotificationToLoadCsv
    
}
@end
