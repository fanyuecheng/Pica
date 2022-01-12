//
//  PCFavouriteComicRequest.h
//  Pica
//
//  Created by YueCheng on 2021/5/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCFavouriteComicRequest : PCRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, copy)   NSString *s;

@end

NS_ASSUME_NONNULL_END
