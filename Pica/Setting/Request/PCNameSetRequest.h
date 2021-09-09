//
//  PCNameSetRequest.h
//  Pica
//
//  Created by Fancy on 2021/9/9.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCNameSetRequest : PCRequest

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;

@end

NS_ASSUME_NONNULL_END
