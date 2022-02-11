//
//  NSFWFile.m
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "NSFWFile.h"
#import "PCDefineHeader.h"

@implementation NSFWFile

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        _path = path;
        _name = path.lastPathComponent;
        BOOL isDirectory;
        [kDefaultFileManager fileExistsAtPath:path isDirectory:&isDirectory];
        _isDirectory = isDirectory;
    }
    return self;
}

@end
