//
//  PCUser.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCThumb.h"
#import "PCLocalKeyHeader.h"

NS_ASSUME_NONNULL_BEGIN
/*
 characters = (
     "knight"
 );
 exp = 1068532;
 slogan = "奥特勋章……我的奥特勋章……
";
 verified = 0;
 _id = "58f649a80a48790773c7017c";
 title = "那位大人";
 level = 103;
 avatar = {
     path = "88674f6a-e721-440e-8673-63bf7210ce1b.jpg";
     originalName = "avatar.jpg";
     fileServer = "https://storage1.picacomic.com";
 };
 role = "knight";
 character = "https://pica-pica.wikawika.xyz/special/frame-467.png";
 gender = "m";
 name = "复活的炎头队长";
 */

@interface PCUser : NSObject

@property (nonatomic, copy)   NSString *userId;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *slogan;
@property (nonatomic, copy)   NSString *role;
@property (nonatomic, copy)   NSString *character;
@property (nonatomic, copy)   NSString *gender;
@property (nonatomic, copy)   NSString *name;
@property (nonatomic, assign) BOOL     verified;
@property (nonatomic, assign) NSInteger exp;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, copy)   NSArray   <NSString *> *characters;
@property (nonatomic, strong) PCThumb   *avatar;
@property (nonatomic, copy)   NSString  *avatarUrl;

//排行
@property (nonatomic, assign) NSInteger comicsUploaded;

//我的
@property (nonatomic, strong) NSDate *created_at;
@property (nonatomic, strong) NSDate *activation_date;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, assign) BOOL isPunched;
@property (nonatomic, copy)   NSString *email;

+ (PCUser *)localUser;
+ (NSArray *)characterImageArray;
+ (NSString *)localCharacterImage;

+ (void)requsetMyself:(nullable void (^)(PCUser *user, NSError *error))finished;

@end

NS_ASSUME_NONNULL_END
