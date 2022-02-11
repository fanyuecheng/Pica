//
//  NSFWFile.h
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFWFile : NSObject

@property (nonatomic, copy, readonly) NSString *path;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, assign, readonly) BOOL isDirectory;

- (instancetype)initWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
