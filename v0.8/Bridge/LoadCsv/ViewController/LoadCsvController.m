//
//  LoadCsvController.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/27.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "LoadCsvController.h"
#import "LoadCsvTreeModel.h"
#import <CWGeneralManager/NSString+Extension.h>
#import <CWGeneralManager/CWFileManager.h>
#import <CWGeneralManager/MyEexception.h>
#import <CWGeneralManager/MyOutlineView.h>


@interface LoadCsvController ()//
@property (weak) IBOutlet MyOutlineView *treeView;
@property (nonatomic,strong) LoadCsvTreeModel *treeModel;
@property (nonatomic,strong) NSButton *lastCsvBtn;
@property (nonatomic,strong) NSButton *lastScriptBtn;
@property (nonatomic,copy) NSString *csvPathName;
@property (nonatomic,copy) NSString *scriptPathName;
@property (weak) IBOutlet NSButton *scriptBtn;

@property (weak) IBOutlet NSTextField *dataTextField;

@property (weak) IBOutlet NSTextField *scriptTextField;
@property (weak) IBOutlet NSTextField *cpkLowView;
@property (weak) IBOutlet NSTextField *cpkHighView;

@end

@implementation LoadCsvController{

    NSString *_scriptDir;
    NSString *_dataDir;
}
//- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
//     NSLog(@"11");
//    return 0;
//}
//
//- (void)draggingExited:(nullable id <NSDraggingInfo>)sender{
//    NSLog(@"11");
//
//}


- (IBAction)checkBtn:(NSButton *)btn {
    NSInteger state = btn.state;
    [self.scriptBtn setEnabled:state];
    self.scriptTextField.stringValue=@"";

}

- (IBAction)removeAll:(NSButton *)btn {

    [self deleteAllFileInPath:_dataDir];
    [self deleteAllFileInPath:_scriptDir];
    [self refresh:nil];
}


-(void)deleteAllFileInPath:(NSString *)path{
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSString *fileName;
    while (fileName= [dirEnum nextObject]) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",path,fileName] error:nil];
    }
}

- (IBAction)removeSelected:(NSButton *)btn {
    NSInteger row = self.treeView.selectedRow;
    if (row<0) {
        return;
    }
    LoadCsvTreeModel *item = [self.treeView itemAtRow:row];
    if ([item.rootName.lowercaseString containsString:@"test data"]) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",_dataDir,item.name] error:nil];
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",_scriptDir,item.name] error:nil];
    }
    [self refresh:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.title = @"Load CSV";
    NSString *deskPath = [NSString cw_getDesktopPath];
    _dataDir =[deskPath stringByAppendingPathComponent:@"CPK_Log/loadFile/data/"];
//    [CWFileManager cw_createFile:_dataDir  isDirectory:YES];
    _scriptDir =[deskPath stringByAppendingPathComponent:@"CPK_Log/loadFile/script/"];
//    [CWFileManager cw_createFile:_scriptDir  isDirectory:YES];

//    NSString *file1 = [[NSBundle mainBundle] pathForResource:@"demo_script.csv" ofType:nil];
//    NSString *file2 = [[NSBundle mainBundle] pathForResource:@"demo_data.csv" ofType:nil];
//    [[NSFileManager defaultManager] copyItemAtPath:file1 toPath:[_scriptDir stringByAppendingPathComponent:file1.lastPathComponent] error:nil];
//    [[NSFileManager defaultManager] copyItemAtPath:file2 toPath:[_dataDir stringByAppendingPathComponent:file2.lastPathComponent] error:nil];
    
//    NSArray *csvDataFiles = [CWFileManager getFilenamelistOfType:@"csv" fromDirPath:_dataDir];
//    NSArray *scriptfiles = [CWFileManager getFilenamelistOfType:@"csv" fromDirPath:_scriptDir];
//    [self treeViewDataConfigWithRootName:@"Test Data File" levelNames:csvDataFiles];
//    [self treeViewDataConfigWithRootName:@"Script File" levelNames:scriptfiles];
    
    
    [self.treeView expandItem:nil expandChildren:YES];
    id item = [self.treeView itemAtRow:1];
    [self.treeView expandItem:item expandChildren:YES];

}


- (IBAction)addScriptClick:(NSButton *)btn {
    
    [CWFileManager openPanel:^(NSString * _Nonnull path) {
        
        self.scriptTextField.stringValue = path;
        [self addFileInTableListWithScriptPath:path];
//        NSString *dataPath =self.dataTextField.stringValue;
//        if (dataPath.length) {
//            [self applyWithCsvFullPath:dataPath scriptFullPath:path];
//        }else{
//            return ;
//        }
    
    }];
    
}


- (IBAction)addDataCsv:(NSButton *)btn {
    

    [CWFileManager openPanel:^(NSString * _Nonnull path) {
        self.dataTextField.stringValue = path;
        [self addFileInTableListWithDataPath:path];
//        if (!self.scriptBtn.isEnabled) {
//
//            [self applyWithCsvFullPath:path scriptFullPath:@""];
//        }
    }];
   
}


-(void)addFileInTableListWithDataPath:(NSString *)filePath{
    [CWFileManager cw_copySourceFileToDestPath:filePath destDir:_dataDir];
    [self refresh:nil];
}
-(void)addFileInTableListWithScriptPath:(NSString *)filePath{
    [CWFileManager cw_copySourceFileToDestPath:filePath destDir:_scriptDir];
    [self refresh:nil];
}

- (IBAction)refresh:(NSButton *)sender {
    
    [self.treeModel.childNodes removeAllObjects];
//    NSString *file1 = [[NSBundle mainBundle] pathForResource:@"demo_script.csv" ofType:nil];
//    NSString *file2 = [[NSBundle mainBundle] pathForResource:@"demo_data.csv" ofType:nil];
//    [[NSFileManager defaultManager] copyItemAtPath:file1 toPath:[_scriptDir stringByAppendingPathComponent:file1.lastPathComponent] error:nil];
//    [[NSFileManager defaultManager] copyItemAtPath:file2 toPath:[_dataDir stringByAppendingPathComponent:file2.lastPathComponent] error:nil];
    
    NSArray *csvDataFiles = [CWFileManager getFilenamelistOfType:@"csv" fromDirPath:_dataDir];
    NSArray *scriptfiles = [CWFileManager getFilenamelistOfType:@"csv" fromDirPath:_scriptDir];
    [self treeViewDataConfigWithRootName:@"Test Data File" levelNames:csvDataFiles];
    [self treeViewDataConfigWithRootName:@"Script File" levelNames:scriptfiles];
    
    [self.treeView expandItem:nil expandChildren:YES];
    id item = [self.treeView itemAtRow:1];
    [self.treeView expandItem:item expandChildren:YES];
    
    
}


- (void)treeViewDataConfigWithRootName:(NSString *)rootName levelNames:(NSArray *)levelNames{
    LoadCsvTreeModel *rootNode = [[LoadCsvTreeModel alloc]init];
    rootNode.name = rootName;
    [self.treeModel.childNodes addObject:rootNode];
    
    for (int i=0; i<levelNames.count; i++) {
        LoadCsvTreeModel *levelNode = [[LoadCsvTreeModel alloc]init];
        levelNode.name = levelNames[i];
        levelNode.rootName = rootName;
        levelNode.index = i;
        [rootNode.childNodes addObject:levelNode];
    }
    
    [self.treeView reloadData];
}


- (LoadCsvTreeModel*)treeModel
{
    if(!_treeModel){
        _treeModel = [[LoadCsvTreeModel alloc]init];
    }
    return _treeModel;
}

#pragma mark- NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    if(!item){
        return [self.treeModel.childNodes count];
    }
    else{
        
        LoadCsvTreeModel *nodeModel = item;
        return [nodeModel.childNodes count];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if(!item){
        return self.treeModel.childNodes[index];
    }
    else{
        
        LoadCsvTreeModel *nodeModel = item;
        return nodeModel.childNodes[index];
    }
}



- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if(!item){
        return [self.treeModel.childNodes count]>0 ;
    }
    else{
        
        LoadCsvTreeModel *nodeModel = item;
        return [nodeModel.childNodes count]>0;
    }
    
    
}


#pragma mark- NSOutlineViewDelegate

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item ;
{
    NSView *result  =  [outlineView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    NSArray *subviews = [result subviews];
    
    NSButton *btn = subviews[1];
    
    NSTextField *field = subviews[0];
    
    LoadCsvTreeModel *model = item;
    
    if (model.childNodes.count) {
        btn.hidden = YES;
    }else{
        btn.hidden = NO;
        btn.tag = model.index;
        btn.target = self;
        if ([model.rootName.lowercaseString containsString:@"test data"]) {
            [btn setAction:@selector(selectedCsvDataBtnClick:)];
        }else{
            [btn setAction:@selector(selectedScriptBtnClick:)];
        }
        
    }
    
    field.stringValue = model.name;
    

    return result;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(nullable NSTableColumn *)tableColumn item:(id)item{
    return YES;
}

- (IBAction)cancelClick:(NSButton *)sender {
    [self close];
}

-(void)selectedCsvDataBtnClick:(NSButton *)btn{
    if (self.lastCsvBtn!=nil && self.lastCsvBtn != btn) {
        [self.lastCsvBtn setState:0];
    }
    self.lastCsvBtn = btn;
    NSInteger index = btn.tag;
    if (btn.state) {
        LoadCsvTreeModel *mode =self.treeModel.childNodes[0];
        _csvPathName = [mode.childNodes[index] name];
    }else{
        _csvPathName=@"";
    }


}
-(void)selectedScriptBtnClick:(NSButton *)btn{
    if (self.lastScriptBtn!=nil&&self.lastScriptBtn != btn) {
        [self.lastScriptBtn setState:0];
    }
    self.lastScriptBtn = btn;
    NSInteger index = btn.tag;
    if (btn.state) {
        LoadCsvTreeModel *mode =self.treeModel.childNodes[1];
        _scriptPathName = [mode.childNodes[index] name];
    }else{
        _scriptPathName=@"";
    }
}

-(void)applyWithCsvFullPath:(NSString *)csvFullPath scriptFullPath:(NSString *)scriptFullPath{
    
    
    if (!csvFullPath.length) {
        return;
    }
    
    
    NSString *fullCsvPathName = csvFullPath;
    if (scriptFullPath.length) {
        NSString *contentString = [CWFileManager cw_readFromFile:fullCsvPathName];
        NSString *versionName =scriptFullPath.lastPathComponent.stringByDeletingPathExtension;
        
        if ([versionName containsString:@"__"]) {
            NSArray *arr = [versionName cw_componentsSeparatedByString:@"__"];
            
            if (arr.count == 2) {
                if ([arr[1] containsString:@"2020"]||[arr[1] containsString:@"2019"]||[arr[1] containsString:@"2021"]) {
                    versionName = [NSString stringWithFormat:@"%@__%@",arr[1],arr[0]];
                }
                
            }
        }

        //NSString *version =
        
        
        if (![contentString.lowercaseString containsString:versionName.lowercaseString]) {
            [MyEexception RemindException:@"Error" Information:@"No version is matched"];
            return;
        }
     
    }
    
    
    NSString *fullScriptPathName =scriptFullPath;
    if (!scriptFullPath.length) {
        fullScriptPathName = @"";
    }
    if (self.loadCsvDelegate && [self.loadCsvDelegate respondsToSelector:@selector(LoadCsvControllerApplyClickWithDataPath:scriptPath:cpkLTHL:cpkHTHL:)]) {
        NSString *cpkLTHL = self.cpkLowView.stringValue.length ? self.cpkLowView.stringValue : self.cpkLowView.placeholderString;
        NSString *cpkHTHL = self.cpkHighView.stringValue.length ? self.cpkHighView.stringValue : self.cpkHighView.placeholderString;
        [self.loadCsvDelegate LoadCsvControllerApplyClickWithDataPath:fullCsvPathName scriptPath:fullScriptPathName cpkLTHL:cpkLTHL cpkHTHL:cpkHTHL];
    }
    
}

-(void)applyWithCsvPathName:(NSString *)csvPathName scriptPathName:(NSString *)scriptPathName{
    
    
    if (!csvPathName.length) {
        return;
    }
    
    NSString *fullCsvPathName = [_dataDir stringByAppendingPathComponent:csvPathName];
    if (scriptPathName.length) {
        NSString *contentString = [CWFileManager cw_readFromFile:fullCsvPathName];
        NSString *versionName =scriptPathName.stringByDeletingPathExtension;
        NSArray *arr = [versionName cw_componentsSeparatedByString:@"__"];
        if (arr.count == 2) {
            versionName = [NSString stringWithFormat:@"%@__%@",arr[1],arr[0]];
        }
        //NSString *version =
        
        
        if (![contentString containsString:versionName]) {
            [MyEexception RemindException:@"Error" Information:@"No version is matched"];
            return;
        }
    }
    
    
    NSString *fullScriptPathName =[_scriptDir stringByAppendingPathComponent:scriptPathName];
    if (!scriptPathName.length) {
        fullScriptPathName = @"";
    }
    if (self.loadCsvDelegate && [self.loadCsvDelegate respondsToSelector:@selector(LoadCsvControllerApplyClickWithDataPath:scriptPath:cpkLTHL:cpkHTHL:)]) {
        NSString *cpkLTHL = self.cpkLowView.stringValue.length ? self.cpkLowView.stringValue : self.cpkLowView.placeholderString;
        NSString *cpkHTHL = self.cpkHighView.stringValue.length ? self.cpkHighView.stringValue : self.cpkHighView.placeholderString;
        [self.loadCsvDelegate LoadCsvControllerApplyClickWithDataPath:fullCsvPathName scriptPath:fullScriptPathName cpkLTHL:cpkLTHL cpkHTHL:cpkHTHL];
    }
    
}

- (IBAction)apply:(NSButton *)sender {
    NSString *dataPath = self.dataTextField.stringValue;
    
    if (!self.scriptBtn.isEnabled) {
        
        if (dataPath.length) {
            [self applyWithCsvFullPath:dataPath scriptFullPath:@""];
        }
        
    }else{
        NSString *scriptPath = self.scriptTextField.stringValue;
        if (dataPath.length && scriptPath.length) {
             [self applyWithCsvFullPath:dataPath scriptFullPath:scriptPath];
        }else{
            return ;
        }
    }
    
    //[self applyWithCsvPathName:_csvPathName scriptPathName:_scriptPathName];
}
//- (IBAction)showFilePath:(NSButton *)sender {
//    [CWFileManager cw_openFileWithPath:_dataDir];
//}


//#pragma mark-- Drag /Drop
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pboard{
//    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:items];
//    
//    [pboard declareTypes:[NSArray arrayWithObject:kDragOutlineViewTypeName] owner:self];
//    
//    [pboard setData:data forType:kDragOutlineViewTypeName];
//    
//    return YES;
//    
//}
//
//- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index {
//    // Add code here to validate the drop
//    
//    NSLog(@"validate Drop");
//    
//    return NSDragOperationEvery;
//}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index {
//    
//    NSPasteboard* pboard = [info draggingPasteboard];
//    
//    NSData* data = [pboard dataForType:kDragOutlineViewTypeName];
//    
//    NSArray* items = [NSKeyedUnarchiver unarchiveObjectWithData:data];
//    
//    NSLog(@"outlineView item %@",item);
//    
//    NSLog(@"drop items %@ index %ld",items,index);
//    
//    id parentItem;
//    
//    if(item) {
//        
//        parentItem = [outlineView parentForItem:item];
//        
//    }
//    else{
//        
//        //  parentItem = self.nodes[[self.nodes count]-1];
//        
//    }
//    
//    NSMutableArray *children = parentItem[@"children"];
//    
//    
//    [children addObjectsFromArray:items];
//    
//    // [self.treeView reloadData];
//    
//    
//    
//    return YES;
//}

@end
