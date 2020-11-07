//
//  LoadCsvTreeModel.m
//  BDR_Tool
//
//  Created by ciwei luo on 2020/6/27.
//  Copyright © 2020 macdev. All rights reserved.
//

#import "LoadCsvTreeModel.h"

@implementation LoadCsvTreeModel

- (NSMutableArray*)childNodes{
    if(!_childNodes){
        _childNodes = [NSMutableArray array];
    }
    
    return _childNodes;
}

@end
