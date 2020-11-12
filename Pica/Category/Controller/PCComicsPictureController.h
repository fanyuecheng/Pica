//
//  PCComicsPictureController.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCComicsPictureController : PCViewController

@property (nonatomic, copy)   NSString *comicsId;
@property (nonatomic, assign) NSInteger order;

- (instancetype)initWithComicsId:(NSString *)comicsId
                           order:(NSInteger)order;

@end

NS_ASSUME_NONNULL_END
