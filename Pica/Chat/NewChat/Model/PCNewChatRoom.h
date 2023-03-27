//
//  PCNewChatRoom.h
//  Pica
//
//  Created by Fancy on 2023/3/23.
//  Copyright © 2023 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCNewChatRoom : NSObject

@property (nonatomic, copy)   NSString *roomId;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *desc;
@property (nonatomic, copy)   NSString *icon;
@property (nonatomic, copy)   NSArray *allowedCharacters;
@property (nonatomic, assign) NSInteger minLevel;
@property (nonatomic, assign) NSInteger minRegisterDays;
@property (nonatomic, assign) BOOL isAvailable;
@property (nonatomic, assign) BOOL isPublic;

@end

NS_ASSUME_NONNULL_END
