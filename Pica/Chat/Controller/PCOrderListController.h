//
//  PCOrderListController.h
//  Pica
//
//  Created by Fancy on 2022/2/10.
//  Copyright © 2022 fancy. All rights reserved.
//

#import "PCTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCOrderListController : PCTableViewController <QMUIModalPresentationContentViewControllerProtocol>

@property (nonatomic, copy) void (^orderBlock)(NSString *order);

@end

NS_ASSUME_NONNULL_END
