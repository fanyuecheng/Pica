//
//  PCProfileHeaderView.h
//  Pica
//
//  Created by YueCheng on 2021/5/27.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class PCUser;
@interface PCProfileHeaderView : UIView

@property (nonatomic, strong) PCUser *user;
@property (nonatomic, copy)   void (^avatarBlock)(void);
@property (nonatomic, copy)   void (^sloganBlock)(void);

- (void)updateAvatar:(UIImage *)avatar; 
- (void)updateSlogan:(NSString *)slogan;

@end

NS_ASSUME_NONNULL_END
