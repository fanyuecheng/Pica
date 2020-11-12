//
//  PCThemeManager.m
//
//
//
//
//

#import "PCThemeManager.h"
#import "PCCommonUI.h"
#import <QMUIKit/QMUIKit.h>

@interface PCThemeManager ()

@property(nonatomic, strong) UIColor *pc_backgroundColor;
@property(nonatomic, strong) UIColor *pc_backgroundColorLighten;
@property(nonatomic, strong) UIColor *pc_backgroundColorHighlighted;
@property(nonatomic, strong) UIColor *pc_tintColor;
@property(nonatomic, strong) UIColor *pc_titleTextColor;
@property(nonatomic, strong) UIColor *pc_mainTextColor;
@property(nonatomic, strong) UIColor *pc_descriptionTextColor;
@property(nonatomic, strong) UIColor *pc_placeholderColor;
@property(nonatomic, strong) UIColor *pc_codeColor;
@property(nonatomic, strong) UIColor *pc_separatorColor;
@property(nonatomic, strong) UIColor *pc_gridItemTintColor;

@property(nonatomic, strong) UIImage *pc_searchBarTextFieldBackgroundImage;
@property(nonatomic, strong) UIImage *pc_searchBarBackgroundImage;

@property(nonatomic, strong) UIVisualEffect *pc_standardBlueEffect;

@property(class, nonatomic, strong, readonly) PCThemeManager *sharedInstance;
@end

@implementation PCThemeManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static PCThemeManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    if (self = [super init]) {
        self.pc_backgroundColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeBackgroundColor;
        }];
        self.pc_backgroundColorLighten = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, NSString * _Nullable identifier, NSObject<PCThemeProtocol> * _Nullable theme) {
            return theme.themeBackgroundColorLighten;
        }];
        self.pc_backgroundColorHighlighted = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeBackgroundColorHighlighted;
        }];
        self.pc_tintColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeTintColor;
        }];
        self.pc_titleTextColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeTitleTextColor;
        }];
        self.pc_mainTextColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeMainTextColor;
        }];
        self.pc_descriptionTextColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeDescriptionTextColor;
        }];
        self.pc_placeholderColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themePlaceholderColor;
        }];
        self.pc_codeColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeCodeColor;
        }];
        self.pc_separatorColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, NSObject<PCThemeProtocol> *theme) {
            return theme.themeSeparatorColor;
        }];
        self.pc_gridItemTintColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, NSString * _Nullable identifier, NSObject<PCThemeProtocol> * _Nullable theme) {
            return theme.themeGridItemTintColor;
        }];
        
        self.pc_searchBarTextFieldBackgroundImage = [UIImage qmui_imageWithThemeProvider:^UIImage * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject<PCThemeProtocol> * _Nullable theme) {
            return [UISearchBar qmui_generateTextFieldBackgroundImageWithColor:theme.themeBackgroundColorHighlighted];
        }];
        self.pc_searchBarBackgroundImage = [UIImage qmui_imageWithThemeProvider:^UIImage * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, __kindof NSObject<NSCopying> * _Nullable identifier, __kindof NSObject<PCThemeProtocol> * _Nullable theme) {
            return [UISearchBar qmui_generateBackgroundImageWithColor:theme.themeBackgroundColor borderColor:nil];
        }];
        
        self.pc_standardBlueEffect = [UIVisualEffect qmui_effectWithThemeProvider:^UIVisualEffect * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, NSString * _Nullable identifier, NSObject<PCThemeProtocol> * _Nullable theme) {
            return [UIBlurEffect effectWithStyle:[identifier isEqualToString:PCThemeIdentifierDark] ? UIBlurEffectStyleDark : UIBlurEffectStyleLight];
        }];
    }
    return self;
}

+ (NSObject<PCThemeProtocol> *)currentTheme {
    return QMUIThemeManagerCenter.defaultThemeManager.currentTheme;
}

@end

@implementation UIColor (QDTheme)

+ (instancetype)pc_sharedInstance {
    static dispatch_once_t onceToken;
    static UIColor *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (UIColor *)pc_backgroundColor {
    return PCThemeManager.sharedInstance.pc_backgroundColor;
}

+ (UIColor *)pc_backgroundColorLighten {
    return PCThemeManager.sharedInstance.pc_backgroundColorLighten;
}

+ (UIColor *)pc_backgroundColorHighlighted {
    return PCThemeManager.sharedInstance.pc_backgroundColorHighlighted;
}

+ (UIColor *)pc_tintColor {
    return PCThemeManager.sharedInstance.pc_tintColor;
}

+ (UIColor *)pc_titleTextColor {
    return PCThemeManager.sharedInstance.pc_titleTextColor;
}

+ (UIColor *)pc_mainTextColor {
    return PCThemeManager.sharedInstance.pc_mainTextColor;
}

+ (UIColor *)pc_descriptionTextColor {
    return PCThemeManager.sharedInstance.pc_descriptionTextColor;
}

+ (UIColor *)pc_placeholderColor {
    return PCThemeManager.sharedInstance.pc_placeholderColor;
}

+ (UIColor *)pc_codeColor {
    return PCThemeManager.sharedInstance.pc_codeColor;
}

+ (UIColor *)pc_separatorColor {
    return PCThemeManager.sharedInstance.pc_separatorColor;
}

+ (UIColor *)pc_gridItemTintColor {
    return PCThemeManager.sharedInstance.pc_gridItemTintColor;
}

@end

@implementation UIImage (QDTheme)

+ (UIImage *)pc_searchBarTextFieldBackgroundImage {
    return PCThemeManager.sharedInstance.pc_searchBarTextFieldBackgroundImage;
}

+ (UIImage *)pc_searchBarBackgroundImage {
    return PCThemeManager.sharedInstance.pc_searchBarBackgroundImage;
}

@end

@implementation UIVisualEffect (QDTheme)

+ (UIVisualEffect *)pc_standardBlurEffect {
    return PCThemeManager.sharedInstance.pc_standardBlueEffect;
}

@end
