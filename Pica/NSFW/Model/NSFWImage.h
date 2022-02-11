//
//  NSFWImage.h
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class UIImage;
@interface NSFWImage : NSObject

@property (nonatomic, copy)   NSString *url;
@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
