//
//  PCPasswordSetRequest.h
//  Pica
//
//  Created by YueCheng on 2021/5/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCPasswordSetRequest : PCRequest

@property (nonatomic, copy) NSString *passwordOld;
@property (nonatomic, copy) NSString *passwordNew;

@end

NS_ASSUME_NONNULL_END
