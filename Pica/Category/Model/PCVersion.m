//
//  PCVersion.m
//  Pica
//
//  Created by Fancy on 2022/3/3.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCVersion.h"

@implementation PCVersion

- (NSString *)version {
    if (self.tag_name) {
        return [self.tag_name stringByReplacingOccurrencesOfString:@"v" withString:@""];
    } else {
        return nil;
    }
}

- (BOOL)isNewVersion {
    NSString *update = self.version;
    NSString *current = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
 
    NSMutableArray *firstArray = [NSMutableArray arrayWithArray:[update componentsSeparatedByString:@"."]];
    NSMutableArray *secondArray = [NSMutableArray arrayWithArray:[current componentsSeparatedByString:@"."]];
    NSInteger count = MAX(firstArray.count, secondArray.count);
    if (firstArray.count < count) {
        for(NSInteger i = firstArray.count; i < count; i++) {
            [firstArray addObject:@"0"];
        }
    }
    if (secondArray.count < count) {
        for(NSInteger i = secondArray.count; i < count; i++) {
            [secondArray addObject:@"0"];
        }
    }
    for (int i = 0; i < count; i++) {
        NSInteger a = [firstArray[i] integerValue];
        NSInteger b = [secondArray[i] integerValue];
        if (a > b) {
            return YES;
        } else if (a < b) {
            return NO;
        }
    }
    return NO;
}
 
@end
