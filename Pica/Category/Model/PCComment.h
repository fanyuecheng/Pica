//
//  PCComment.h
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCUser.h"

NS_ASSUME_NONNULL_BEGIN

/*
 _id = "5e400f93cb42dc1465a055c9";
 content = "各位如果要看rocksylight最新到2020年2月為止露批照片和視頻的話，搜索CUTE CAT，第一那個3d作品的簡介就有下載地址";
 _comic = "5e400e1c6d8c2c397136bcf7";
 isTop = 1;
 hide = 0;
 created_at = "2020-02-09T13:56:35.203Z";
 _user = {
     characters = (
         "knight"
     );
     exp = 328850;
     slogan = "性愛教父";
     verified = 0;
     _id = "58f3affec685083f0285470f";
     title = "獵批🐱殺手";
     level = 57;
     avatar = {
         path = "dd377c71-e3fb-4122-b952-468fbbe8a93e.jpg";
         originalName = "avatar.jpg";
         fileServer = "https://storage1.picacomic.com";
     };
     role = "knight";
     character = "https://pica-pica.wikawika.xyz/special/frame-165.png";
     gender = "m";
     name = "pussy killer";
 };
 commentsCount = 73;
 likesCount = 1104;
 isLiked = 0;
 ip = "";
 */

typedef NS_ENUM(NSUInteger, PCCommentType) {
    PCCommentTypeComic,
    PCCommentTypeGame
};

@interface PCComment : NSObject

@property (nonatomic, copy)   NSString *commentId;
@property (nonatomic, copy)   NSString *content;
@property (nonatomic, copy)   NSString *ip;
@property (nonatomic, assign) BOOL     isTop;
@property (nonatomic, assign) BOOL     isLiked;
@property (nonatomic, assign) BOOL     hide;
@property (nonatomic, strong) NSDate   *created_at;
@property (nonatomic, strong) PCUser   *user;
@property (nonatomic, strong) NSString *comic;
@property (nonatomic, strong) NSString *game;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger likesCount;

//custom
@property (nonatomic, assign) BOOL     isChild;

+ (PCComment *)commentWithContent:(NSString *)content isChild:(BOOL)isChild;

@end

@interface PCComicsComment : NSObject

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, copy)   NSArray <PCComment *> *topComments;
@property (nonatomic, copy)   NSArray <PCComment *> *docs;
 
@end

NS_ASSUME_NONNULL_END
