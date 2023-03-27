//
//  PCLoginController.h
//  Pica
//
//  Created by fancy on 2020/11/2.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCViewController.h"
#import "PCLoginRequest.h"
#import "PCNewChatLoginRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCLoginController : PCViewController
 
@property (nonatomic, assign) BOOL isNewChatLogin;
@property (nonatomic, copy)   void (^loginBlock)(BOOL isNewChatLogin);

@end

NS_ASSUME_NONNULL_END
