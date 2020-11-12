//
//  PCThemeManager.h
//
//
//
//
//

#import <Foundation/Foundation.h>
#import "PCThemeProtocol.h"

/// 简单对 QMUIThemeManager 做一层业务的封装，省去类型转换的工作量
NS_ASSUME_NONNULL_BEGIN

@interface PCThemeManager : NSObject

@property(class, nonatomic, readonly, nullable) NSObject<PCThemeProtocol> *currentTheme;
@end

@interface UIColor (QDTheme)

@property(class, nonatomic, strong, readonly) UIColor *pc_backgroundColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_backgroundColorLighten;
@property(class, nonatomic, strong, readonly) UIColor *pc_backgroundColorHighlighted;
@property(class, nonatomic, strong, readonly) UIColor *pc_tintColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_titleTextColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_mainTextColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_descriptionTextColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_placeholderColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_codeColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_separatorColor;
@property(class, nonatomic, strong, readonly) UIColor *pc_gridItemTintColor;
@end

@interface UIImage (QDTheme)

@property(class, nonatomic, strong, readonly) UIImage *pc_searchBarTextFieldBackgroundImage;
@property(class, nonatomic, strong, readonly) UIImage *pc_searchBarBackgroundImage;
@end

@interface UIVisualEffect (QDTheme)

@property(class, nonatomic, strong, readonly) UIVisualEffect *pc_standardBlurEffect;
@end

NS_ASSUME_NONNULL_END
