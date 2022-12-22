//
//  PCUIHelper.m
//   
//
//
//
//

#import "PCUIHelper.h"
#import "PCCommonUI.h"
#import "PCThemeManager.h"

@implementation PCUIHelper

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ExtendImplementationOfNonVoidMethodWithSingleArgument([UIControl class], @selector(initWithFrame:), CGRect, UIControl *, ^UIControl *(UIControl *selfObject, CGRect firstArgv, UIControl * originReturnValue) {
            ({
                NSArray<Class> *controlClasses = @[
                    NSClassFromString(@"_UIButtonBarButton"),// iOS 11 及以后的 UIBarButtonItem 按钮
                    NSClassFromString(@"UINavigationButton"),// iOS 10 的 UIBarButtonItem 按钮
                    QMUIButton.class,
                    QMUINavigationButton.class
                ];
                for (Class className in controlClasses) {
                    if ([selfObject isKindOfClass:className]) {
                        originReturnValue.qmui_preventsRepeatedTouchUpInsideEvent = YES;
                        break;
                    }
                }
            });
            return originReturnValue;
        });
    });
}

@end


@implementation PCUIHelper (PCMoreOperationAppearance)

+ (void)customMoreOperationAppearance {
    // 如果需要统一修改全局的 QMUIMoreOperationController 样式，在这里修改 appearance 的值即可
    [QMUIMoreOperationController appearance].cancelButtonTitleColor = UIColor.pc_tintColor;
}

@end


@implementation PCUIHelper (PCAlertControllerAppearance)

+ (void)customAlertControllerAppearance {
    // 如果需要统一修改全局的 QMUIAlertController 样式，在这里修改 appearance 的值即可
}

@end

@implementation PCUIHelper (PCDialogViewControllerAppearance)

+ (void)customDialogViewControllerAppearance {
    // 如果需要统一修改全局的 QMUIDialogViewController 样式，在这里修改 appearance 的值即可
    QMUIDialogViewController *appearance = [QMUIDialogViewController appearance];
    appearance.backgroundColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, NSString * _Nullable identifier, NSObject<PCThemeProtocol> * _Nullable theme) {
        if ([identifier isEqualToString:PCThemeIdentifierDark]) {
            return UIColorMake(34, 34, 34);
        }
        return UIColorWhite;
    }];
    appearance.headerViewBackgroundColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, NSString * _Nullable identifier, NSObject<PCThemeProtocol> * _Nullable theme) {
        if ([identifier isEqualToString:PCThemeIdentifierDark]) {
            return UIColorMake(34, 34, 34);
        }
        return UIColorMake(244, 245, 247);
    }];
    appearance.contentViewBackgroundColor = appearance.backgroundColor;
    appearance.headerSeparatorColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, NSString * _Nullable identifier, NSObject<PCThemeProtocol> * _Nullable theme) {
        if ([identifier isEqualToString:PCThemeIdentifierDark]) {
            return UIColorMake(51, 51, 51);
        }
        return UIColorMake(222, 224, 226);
    }];
    appearance.footerSeparatorColor = appearance.headerSeparatorColor;
    
    NSMutableDictionary<NSString *, id> *buttonTitleAttributes = [appearance.buttonTitleAttributes mutableCopy];
    buttonTitleAttributes[NSForegroundColorAttributeName] = UIColor.pc_tintColor;
    appearance.buttonTitleAttributes = [buttonTitleAttributes copy];
    
    appearance.buttonHighlightedBackgroundColor = [UIColor.pc_tintColor colorWithAlphaComponent:.25];
}

@end


@implementation PCUIHelper (PCEmotionView)

+ (void)customEmotionViewAppearance {
    [QMUIEmotionView appearance].emotionSize = CGSizeMake(24, 24);
    [QMUIEmotionView appearance].minimumEmotionHorizontalSpacing = 14;
    [QMUIEmotionView appearance].sendButtonBackgroundColor = UIColor.pc_tintColor;
}

@end

@implementation PCUIHelper (PCImagePicker)

+ (void)customImagePickerAppearance {
    UIImage *checkboxImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox"];
    UIImage *checkboxCheckedImage = [QMUIHelper imageWithName:@"QMUI_pickerImage_checkbox_checked"];
    [QMUIImagePickerCollectionViewCell appearance].checkboxImage = [checkboxImage qmui_imageWithTintColor:UIColor.pc_tintColor];
    [QMUIImagePickerCollectionViewCell appearance].checkboxCheckedImage = [checkboxCheckedImage qmui_imageWithTintColor:UIColor.pc_tintColor];
    [QMUIImagePickerPreviewViewController appearance].toolBarTintColor = UIColor.pc_tintColor;
}

@end

@implementation PCUIHelper (PCPopupContainerView)

+ (void)customPopupAppearance {
    QMUIPopupContainerView *popup = QMUIPopupContainerView.appearance;
    popup.backgroundColor = UIColor.pc_backgroundColor;
    popup.borderColor = UIColor.pc_separatorColor;
    popup.maskViewBackgroundColor = [UIColor qmui_colorWithThemeProvider:^UIColor * _Nonnull(__kindof QMUIThemeManager * _Nonnull manager, NSString * _Nullable identifier, __kindof NSObject<PCThemeProtocol> * _Nullable theme) {
        return [identifier isEqual:PCThemeIdentifierDark] ? UIColorMask : UIColorMaskWhite;
    }];
    
    QMUIPopupMenuView *menuView = QMUIPopupMenuView.appearance;
    menuView.itemSeparatorColor = UIColor.pc_separatorColor;
    menuView.sectionSeparatorColor = UIColor.pc_separatorColor;
    menuView.itemTitleColor = UIColor.pc_tintColor;
}

@end

@implementation PCUIHelper (PCTabBarItem)

+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag {
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:tag];
    tabBarItem.selectedImage = selectedImage;
    return tabBarItem;
}

@end


@implementation PCUIHelper (PCButton)

+ (QMUIButton *)generateDarkFilledButton {
    QMUIButton *button = [[QMUIButton alloc] qmui_initWithSize:CGSizeMake(200, 40)];
    button.adjustsButtonWhenHighlighted = YES;
    button.titleLabel.font = UIFontBoldMake(14);
    [button setTitleColor:UIColorWhite forState:UIControlStateNormal];
    button.backgroundColor = UIColor.pc_tintColor;
    button.highlightedBackgroundColor = [UIColor.pc_tintColor qmui_transitionToColor:UIColorBlack progress:.15];// 高亮时的背景色
    button.layer.cornerRadius = 4;
    return button;
}

+ (QMUIButton *)generateLightBorderedButton {
    QMUIButton *button = [[QMUIButton alloc] qmui_initWithSize:CGSizeMake(200, 40)];
    button.titleLabel.font = UIFontBoldMake(14);
    button.tintColorAdjustsTitleAndImage = UIColor.pc_tintColor;
    button.backgroundColor = [UIColor.pc_tintColor qmui_transitionToColor:UIColorWhite progress:.9];
    button.highlightedBackgroundColor = [UIColor.pc_tintColor qmui_transitionToColor:UIColorWhite progress:.75];// 高亮时的背景色
    button.layer.borderColor = [button.backgroundColor qmui_transitionToColor:UIColor.pc_tintColor progress:.5].CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 4;
    button.highlightedBorderColor = [button.backgroundColor qmui_transitionToColor:UIColor.pc_tintColor progress:.9];// 高亮时的边框颜色
    return button;
}

@end


@implementation PCUIHelper (PCEmotion)

NSString *const QMUIEmotionString = @"01-[微笑];02-[开心];03-[生气];04-[委屈];05-[亲亲];06-[坏笑];07-[鄙视];08-[啊]";

static NSArray<QMUIEmotion *> *QMUIEmotionArray;

+ (NSArray<QMUIEmotion *> *)qmuiEmotions {
    if (QMUIEmotionArray) {
        return QMUIEmotionArray;
    }
    
    NSMutableArray<QMUIEmotion *> *emotions = [[NSMutableArray alloc] init];
    NSArray<NSString *> *emotionStringArray = [QMUIEmotionString componentsSeparatedByString:@";"];
    for (NSString *emotionString in emotionStringArray) {
        NSArray<NSString *> *emotionItem = [emotionString componentsSeparatedByString:@"-"];
        NSString *identifier = [NSString stringWithFormat:@"emotion_%@", emotionItem.firstObject];
        QMUIEmotion *emotion = [QMUIEmotion emotionWithIdentifier:identifier displayName:emotionItem.lastObject];
        [emotions addObject:emotion];
    }
    
    QMUIEmotionArray = [NSArray arrayWithArray:emotions];
    [self asyncLoadImages:emotions];
    return QMUIEmotionArray;
}

// 在子线程预加载
+ (void)asyncLoadImages:(NSArray<QMUIEmotion *> *)emotions {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (QMUIEmotion *e in emotions) {
            e.image = [UIImageMake(e.identifier) qmui_imageWithBlendColor:UIColor.pc_tintColor];
        }
    });
}

+ (void)updateEmotionImages {
    [self asyncLoadImages:[self qmuiEmotions]];
}

@end


@implementation PCUIHelper (PCSavePhoto)

+ (void)showAlertWhenSavedPhotoFailureByPermissionDenied {
    NSString *tipString = nil;
    NSDictionary *mainInfoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appName = [mainInfoDictionary objectForKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [mainInfoDictionary objectForKey:(NSString *)kCFBundleNameKey];
    }
    tipString = [NSString stringWithFormat:@"请在设备的\"设置-隐私-照片\"选项中，允许%@访问你的手机相册", appName];
    
    QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"无法保存" message:tipString preferredStyle:QMUIAlertControllerStyleAlert];
    
    QMUIAlertAction *okAction = [QMUIAlertAction actionWithTitle:@"我知道了" style:QMUIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    
    [alertController showWithAnimated:YES];
}

@end


@implementation PCUIHelper (Calculate)

+ (NSString *)humanReadableFileSize:(long long)size {
    NSString * strSize = nil;
    if (size >= 1048576.0) {
        strSize = [NSString stringWithFormat:@"%.2fM", size / 1048576.0f];
    } else if (size >= 1024.0) {
        strSize = [NSString stringWithFormat:@"%.2fK", size / 1024.0f];
    } else {
        strSize = [NSString stringWithFormat:@"%.2fB", size / 1.0f];
    }
    return strSize;
}

@end


@implementation PCUIHelper (Theme)

+ (UIImage *)navigationBarBackgroundImageWithThemeColor:(UIColor *)color {
    CGSize size = CGSizeMake(4, 88);
    color = color ? color : UIColorClear;
    
    UIImage *resultImage = [UIImage qmui_imageWithSize:size opaque:YES scale:0 actions:^(CGContextRef contextRef) {
        CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
        CGGradientRef gradient = CGGradientCreateWithColors(spaceRef, (CFArrayRef)@[(id)color.CGColor, (id)[color qmui_colorWithAlphaAddedToWhite:.86].CGColor], NULL);
        CGContextDrawLinearGradient(contextRef, gradient, CGPointZero, CGPointMake(0, size.height), kCGGradientDrawsBeforeStartLocation);
        CGColorSpaceRelease(spaceRef);
        CGGradientRelease(gradient);
    }];
    return [resultImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1) resizingMode:UIImageResizingModeStretch];
}

@end


@implementation NSString (Code)

- (void)enumerateCodeStringUsingBlock:(void (^)(NSString *, NSRange))block {
    NSString *pattern = @"\\[?[A-Za-z0-9_.\\(]+\\s?[A-Za-z0-9_:.\\)]+\\]?";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    [regex enumerateMatchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result.range.length > 0) {
            if (block) {
                block([self substringWithRange:result.range], result.range);
            }
        }
    }];
}

@end
