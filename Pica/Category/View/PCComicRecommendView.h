//
//  PCComicRecommendView.h
//  Pica
//
//  Created by Fancy on 2022/3/2.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PCComic;
@interface PCComicRecommendView : UIView

@property (nonatomic, copy) NSArray <PCComic *>*comicArray;

@end

NS_ASSUME_NONNULL_END
