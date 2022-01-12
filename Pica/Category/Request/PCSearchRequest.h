//
//  PCSearchRequest.h
//  Pica
//
//  Created by fancy on 2020/11/4.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCComic.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCSearchRequest : PCRequest

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, copy) NSArray  *categories;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *sort;

- (instancetype)initWithKeyword:(NSString *)keyword;

@end

NS_ASSUME_NONNULL_END
