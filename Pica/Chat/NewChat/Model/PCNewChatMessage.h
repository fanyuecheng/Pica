//
//  PCNewChatMessage.h
//  Pica
//
//  Created by Fancy on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCUser.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PCNewChatMessageType) {
    PCNewChatMessageTypeUnknow,
    PCNewChatMessageTypeText,
    PCNewChatMessageTypeImage
};

@interface PCNewChatMessage : NSObject

@property (nonatomic, copy)   NSString *messageId;
@property (nonatomic, copy)   NSString *referenceId;
@property (nonatomic, copy)   NSString *type;
@property (nonatomic, assign) BOOL     isBlocked;

//reply
@property (nonatomic, copy)   NSString *replyImage;
@property (nonatomic, copy)   NSString *replyMessage;
@property (nonatomic, copy)   NSString *replyMessageId;
@property (nonatomic, copy)   NSString *replyMessageType;
@property (nonatomic, copy)   NSString *replyUserName;

//message
@property (nonatomic, strong) NSDate   *date;
@property (nonatomic, copy)   NSString *message;
@property (nonatomic, copy)   NSString *caption;
@property (nonatomic, copy)   NSArray  *medias;
 
//at
@property (nonatomic, copy)   NSArray <PCUser *> *userMentions;

//sender
@property (nonatomic, strong) PCUser *profile;

//custom
@property (nonatomic, strong) UIImage  *image;
@property (nonatomic, assign, readonly) PCNewChatMessageType messageType;

@end
 

NS_ASSUME_NONNULL_END
