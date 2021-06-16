//
//  PCComicsEpisodeRequest.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCRequest.h"
#import "PCEpisode.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicsEpisodeRequest : PCRequest

@property (nonatomic, copy)   NSString *comicsId;
@property (nonatomic, assign) NSInteger page;

- (instancetype)initWithComicsId:(NSString *)comicsId;

@end

NS_ASSUME_NONNULL_END
