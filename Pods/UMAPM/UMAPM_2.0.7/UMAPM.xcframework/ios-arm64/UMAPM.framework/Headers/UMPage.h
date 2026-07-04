//
//  UMPage.h
//  WPKCore
//
//  Created by liuwei on 2022/6/16.
//  Copyright © 2022 uc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMPage : NSObject

+ (void)trackBegin:(NSString *)methodName viewController:(UIViewController *)vc;
+ (void)trackEnd:(NSString *)methodName viewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
