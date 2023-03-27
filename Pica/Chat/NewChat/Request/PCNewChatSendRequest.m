//
//  PCNewChatSendRequest.m
//  Pica
//
//  Created by 米画师 on 2023/3/27.
//  Copyright © 2023 fancy. All rights reserved.
//

#import "PCNewChatSendRequest.h"
#import "PCVendorHeader.h"
#import "PCDefineHeader.h"
#import "AFURLRequestSerialization.h"
 
@implementation PCNewChatSendRequest

- (void)sendRequest:(void (^)(id response))success
            failure:(void (^)(NSError *error))failure {
    [super sendRequest:success failure:failure];
    
    if (self.image) {
        @weakify(self)
        self.constructingBodyBlock = ^(id <AFMultipartFormData>  _Nonnull formData) {
            @strongify(self)
            SDImageFormat fomat = [NSData sd_imageFormatForImageData:self.image];
            NSString *fileName = nil;
            NSString *mimeType = nil;
            switch (fomat) {
                case SDImageFormatGIF:
                    fileName = @"gif";
                    mimeType = @"image/gif";
                    break;
                case SDImageFormatJPEG:
                    fileName = @"jpg";
                    mimeType = @"image/jpeg";
                    break;
                case SDImageFormatPNG:
                    fileName = @"png";
                    mimeType = @"image/png";
                    break;
                default:
                    fileName = @"png";
                    mimeType = @"image/png";
                    self.image = UIImagePNGRepresentation([UIImage imageWithData:self.image]);
                    break;
            }
            [formData appendPartWithFileData:self.image name:@"images" fileName:fileName mimeType:mimeType];
        };
    }
    
    [self startWithCompletionBlockWithSuccess:^(__kindof YTKBaseRequest * _Nonnull request) {
        PCNewChatMessage *message = [PCNewChatMessage yy_modelWithJSON:request.responseJSONObject];
        !success ? : success(message);
    } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
        !failure ? : failure(request.error);
    }];
}

- (NSString *)requestUrl {
    return self.image ? PC_API_NEW_CHAT_SEND_IMG : PC_API_NEW_CHAT_SEND_TXT;
}

- (YTKRequestSerializerType)requestSerializerType {
    return self.image ? YTKRequestSerializerTypeHTTP : YTKRequestSerializerTypeJSON;
}

- (id)requestArgument {
    NSMutableDictionary *argument = [NSMutableDictionary dictionary];
    argument[@"referenceId"] = [NSUUID UUID].UUIDString;
    if (self.roomId) {
        argument[@"roomId"] = self.roomId;
    }
    if (self.image) {
        argument[@"images"] = self.image;
    }
    if (self.message) {
        if (self.image) {
            argument[@"caption"] = self.message;
        } else {
            argument[@"message"] = self.message;
        }
    }
    if (self.userMentions.count) {
        NSMutableArray *userMentions = [NSMutableArray array];
        [self.userMentions enumerateObjectsUsingBlock:^(PCUser * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [userMentions addObject:@{@"id" : obj.userId, @"name" : obj.name}];
        }];
        argument[@"userMentions"] = self.userMentions;
    } else {
        argument[@"userMentions"] = @[];
    }
    if (self.replyMessage) {
        argument[@"reply"] = @{
                                @"id" : self.replyMessage.messageId,
                                @"name" : self.replyMessage.profile.name,
                                @"type" : self.replyMessage.type,
                                @"image" : self.replyMessage.medias.firstObject ? self.replyMessage.medias.firstObject : NSNull.null,
                                @"message" : self.replyMessage.message ? self.replyMessage.message : NSNull.null
                                };
    }
    return argument;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    NSMutableDictionary *header = [super requestHeaderFieldValueDictionary].mutableCopy;
    header[@"authorization"] = [NSString stringWithFormat:@"Bearer %@", [kPCUserDefaults stringForKey:PC_NEW_CHAT_AUTHORIZATION_TOKEN]];
    if (self.image) {
        [header removeObjectForKey:@"content-type"];
    }
    return header;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodPOST;
}

@end
