//
//  PCComicPictureRequest.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCPicture.h"
#import "PCEpisode.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicPictureRequest : PCRequest

@property (nonatomic, copy)   NSString *comicId;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, assign) NSInteger page;

- (instancetype)initWithComicId:(NSString *)comicId
                          order:(NSInteger)order;

@end

NS_ASSUME_NONNULL_END
