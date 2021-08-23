//
//  PCColorSlider.h
//  Pica
//
//  Created by Fancy on 2021/7/14.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PCColorSliderType) {
    PCColorSliderTypeRed,
    PCColorSliderTypeGreen,
    PCColorSliderTypeBlue
};

@interface PCColorSlider : UIView

@property (nonatomic, copy)   void (^valueBlock)(NSInteger value);
@property (nonatomic, assign) PCColorSliderType type;
@property (nonatomic, assign, readonly) NSInteger value;

@end

NS_ASSUME_NONNULL_END
