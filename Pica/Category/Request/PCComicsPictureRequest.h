//
//  PCComicsPictureRequest.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCPicture.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicsPictureRequest : PCRequest

@property (nonatomic, copy)   NSString *comicsId;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) NSInteger page;

- (instancetype)initWithComicsId:(NSString *)comicsId
                           order:(NSInteger)order;

@end

NS_ASSUME_NONNULL_END
