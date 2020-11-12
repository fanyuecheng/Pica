//
//  AppDelegate.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

- (void)setRootViewControllerToLogin;
- (void)setRootViewControllerToTab;

@end

