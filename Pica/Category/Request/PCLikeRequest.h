//
//  PCLikeRequest.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCLikeRequest : PCRequest
 
- (instancetype)initWithComicId:(NSString *)comicId;
- (instancetype)initWithGameId:(NSString *)gameId;

@end

NS_ASSUME_NONNULL_END
