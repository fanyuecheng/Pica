//
//  PCThumb.m
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCThumb.h"

@implementation PCThumb

- (NSString *)imageURL {
    if ([self.fileServer isEqualToString:@"https://wikawika.xyz/static/"]) {
        self.fileServer = @"https://storage.wikawika.xyz";
    }
    if (self.fileServer && self.path) {
        NSString *urlString = [NSString stringWithFormat:@"%@/static/%@", self.fileServer, self.path];
        return urlString;
    } else {
        return nil;
    }
}

@end
