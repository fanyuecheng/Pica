//
//  PCComicFavouriteRequest.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicFavouriteRequest : PCRequest

@property (nonatomic, copy) NSString *comicId;
- (instancetype)initWithComicId:(NSString *)comicId;

@end

NS_ASSUME_NONNULL_END
