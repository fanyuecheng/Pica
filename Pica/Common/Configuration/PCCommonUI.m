//
//  PCCommonUI.m
//
//
//
//
//

#import "PCCommonUI.h"
#import "PCUIHelper.h"

NSString *const PCSelectedThemeIdentifier = @"selectedThemeIdentifier";
NSString *const PCThemeIdentifierDefault = @"Default";
NSString *const PCThemeIdentifierGrapefruit = @"Grapefruit";
NSString *const PCThemeIdentifierGrass = @"Grass";
NSString *const PCThemeIdentifierPinkRose = @"Pink Rose";
NSString *const PCThemeIdentifierDark = @"Dark";

const CGFloat PCButtonSpacingHeight = 72;

@implementation PCCommonUI

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 统一设置所有 QMUISearchController 搜索状态下的 statusBarStyle
        OverrideImplementation([QMUISearchController class], @selector(initWithContentsViewController:), ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
            return ^QMUISearchController *(QMUISearchController *selfObject, UIViewController *firstArgv) {
                
                // call super
                QMUISearchController *(*originSelectorIMP)(id, SEL, UIViewController *);
                originSelectorIMP = (QMUISearchController * (*)(id, SEL, UIViewController *))originalIMPProvider();
                QMUISearchController *result = originSelectorIMP(selfObject, originCMD, firstArgv);
                
                result.qmui_preferredStatusBarStyleBlock = ^UIStatusBarStyle{
                    if ([QMUIThemeManagerCenter.defaultThemeManager.currentThemeIdentifier isEqual:PCThemeIdentifierDark]) {
                        return UIStatusBarStyleLightContent;
                    }
                    return UIStatusBarStyleDarkContent;
                };
                return result;
            };
        });
    });
}

+ (void)renderGlobalAppearances {
    [PCUIHelper customMoreOperationAppearance];
    [PCUIHelper customAlertControllerAppearance];
    [PCUIHelper customDialogViewControllerAppearance];
    [PCUIHelper customImagePickerAppearance];
    [PCUIHelper customEmotionViewAppearance];
    [PCUIHelper customPopupAppearance];
    
    UISearchBar *searchBar = [UISearchBar appearance];
    searchBar.searchTextPositionAdjustment = UIOffsetMake(4, 0);
    
    QMUILabel *label = [QMUILabel appearance];
    label.highlightedBackgroundColor = TableViewCellSelectedBackgroundColor;
}

@end

@implementation PCCommonUI (PCThemeColor)

static NSArray<UIColor *> *themeColors = nil;
+ (UIColor *)randomThemeColor {
    if (!themeColors) {
        themeColors = @[UIColorTheme1,
                        UIColorTheme2,
                        UIColorTheme3,
                        UIColorTheme4,
                        UIColorTheme5,
                        UIColorTheme6,
                        UIColorTheme7,
                        UIColorTheme8,
                        UIColorTheme9,
                        UIColorTheme10];
    }
    return themeColors[arc4random() % themeColors.count];
}

@end

@implementation PCCommonUI (PCLayer)

+ (CALayer *)generateSeparatorLayer {
    CALayer *layer = [CALayer layer];
    [layer qmui_removeDefaultAnimations];
    layer.backgroundColor = UIColorSeparator.CGColor;
    return layer;
}

@end
