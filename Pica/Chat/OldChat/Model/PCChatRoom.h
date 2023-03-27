//
//  PCChatRoom.h
//  Pica
//
//  Created by Fancy on 2021/6/11.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCChatRoom : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *socketUrl;

@end

NS_ASSUME_NONNULL_END
