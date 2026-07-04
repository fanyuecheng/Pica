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
    if (self.fileServer && self.path) {
        if ([self.fileServer containsString:@"static"] || [self.fileServer containsString:@"bidobido"]) {
            NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.fileServer, self.path];
            return urlString;
        } else {
            NSString *urlString = [NSString stringWithFormat:@"%@/static/%@", self.fileServer, self.path];
            return urlString;
        }
    } else {
        return nil;
    }
}

@end
