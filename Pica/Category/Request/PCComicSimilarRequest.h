//
//  PCComicSimilarRequest.h
//  Pica
//
//  Created by Fancy on 2022/3/1.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicSimilarRequest : PCRequest

@property (nonatomic, copy) NSString *comicId;
- (instancetype)initWithComicId:(NSString *)comicId;

@end

NS_ASSUME_NONNULL_END
