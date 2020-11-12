//
//  NSData+PCAdd.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (PCAdd)

- (NSString *)pc_hmacSHA256StringWithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
