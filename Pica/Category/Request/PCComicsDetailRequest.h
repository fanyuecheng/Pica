//
//  PCComicsDetailRequest.h
//  Pica
//
//  Created by fancy on 2020/11/5.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCComics.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicsDetailRequest : PCRequest

@property (nonatomic, copy) NSString *comicsId;
- (instancetype)initWithComicsId:(NSString *)comicsId;

@end

NS_ASSUME_NONNULL_END
