//
//  PCAvatarSetRequest.h
//  Pica
//
//  Created by YueCheng on 2021/5/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class UIImage;
@interface PCAvatarSetRequest : PCRequest

@property (nonatomic, strong) UIImage *avatar;

@end

NS_ASSUME_NONNULL_END
