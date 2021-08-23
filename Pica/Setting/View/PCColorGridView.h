//
//  PCColorGridView.h
//  Pica
//
//  Created by Fancy on 2021/7/14.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCColorGridView : UIView

@property (nonatomic, copy) void (^colorBlock)(UIColor *color);

@end

NS_ASSUME_NONNULL_END
