//
//  PCGameDetailRequest.h
//  Pica
//
//  Created by Fancy on 2021/6/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCGameDetailRequest : PCRequest

@property (nonatomic, copy) NSString *gameId;

@end

NS_ASSUME_NONNULL_END
