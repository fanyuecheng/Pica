//
//  PCMessageBubbleView.h
//  Pica
//
//  Created by Fancy on 2021/6/15.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCMessageBubbleView : UIView

@property (nonatomic, assign) CGSize  arrowSize;      //(4, 7)
@property (nonatomic, assign) CGFloat cornerRadius;   // 4
@property (nonatomic, assign) CGFloat arrowMaxY;      // 6
@property (nonatomic, assign) BOOL    arrowLeft;
@property (nonatomic, strong) UIColor *fillColor;

@end

NS_ASSUME_NONNULL_END
