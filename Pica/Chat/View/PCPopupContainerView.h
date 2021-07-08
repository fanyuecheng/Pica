//
//  PCPopupContainerView.h
//  Pica
//
//  Created by Fancy on 2021/7/6.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCPopupContainerView : QMUIPopupContainerView

@property (nonatomic, copy) NSArray *titleArray;
@property (nonatomic, copy) void (^actionBlock)(PCPopupContainerView *view, NSInteger index);

@end

NS_ASSUME_NONNULL_END
