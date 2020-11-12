//
//  PCUIHelper.h
//
//
//
//
//

#import <Foundation/Foundation.h>
#import <QMUIKit/QMUIKit.h>

@interface PCUIHelper : NSObject

+ (void)forceInterfaceOrientationPortrait;

@end


@interface PCUIHelper (PCMoreOperationAppearance)

+ (void)customMoreOperationAppearance;

@end


@interface PCUIHelper (PCAlertControllerAppearance)

+ (void)customAlertControllerAppearance;

@end

@interface PCUIHelper (PCDialogViewControllerAppearance)

+ (void)customDialogViewControllerAppearance;

@end


@interface PCUIHelper (PCEmotionView)

+ (void)customEmotionViewAppearance;
@end


@interface PCUIHelper (PCImagePicker)

+ (void)customImagePickerAppearance;

@end

@interface PCUIHelper (PCPopupContainerView)

+ (void)customPopupAppearance;
@end


@interface PCUIHelper (PCTabBarItem)

+ (UITabBarItem *)tabBarItemWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage tag:(NSInteger)tag;

@end


@interface PCUIHelper (PCButton)

+ (QMUIButton *)generateDarkFilledButton;
+ (QMUIButton *)generateLightBorderedButton;

@end


@interface PCUIHelper (PCEmotion)

+ (NSArray<QMUIEmotion *> *)qmuiEmotions;

/// 用于主题更新后，更新表情 icon 的颜色
+ (void)updateEmotionImages;
@end


@interface PCUIHelper (PCSavePhoto)

+ (void)showAlertWhenSavedPhotoFailureByPermissionDenied;

@end


@interface PCUIHelper (PCCalculate)

+ (NSString *)humanReadableFileSize:(long long)size;
    
@end


@interface PCUIHelper (PCTheme)

+ (UIImage *)navigationBarBackgroundImageWithThemeColor:(UIColor *)color;
@end


@interface NSString (PCCode)

- (void)enumerateCodeStringUsingBlock:(void (^)(NSString *codeString, NSRange codeRange))block;

@end

