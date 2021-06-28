//
//  PCGame.h
//  Pica
//
//  Created by Fancy on 2021/6/25.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 _id = "6094e3ff761e714f3a260bb0";
 ios = 0;
 adult = 0;
 title = "火影忍者: 羈絆";
 version = "1.0.0";
 publisher = "Fantasy Game";
 suggest = 0;
 android = 1;
 icon = {
     path = "4c87d0bf-61d5-4326-8446-5b4674c157ea.png";
     originalName = "512 (3).png";
     fileServer = "https://storage1.picacomic.com";
 };
 */

@class PCThumb;
@interface PCGame : NSObject

@property (nonatomic, copy)   NSString *gameId;
@property (nonatomic, assign) BOOL ios;
@property (nonatomic, assign) BOOL android;
@property (nonatomic, assign) BOOL adult;
@property (nonatomic, assign) BOOL suggest;
@property (nonatomic, strong) PCThumb *icon;
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *version;
@property (nonatomic, copy)   NSString *publisher;

//detail
@property (nonatomic, copy)   NSString *updateContent;
@property (nonatomic, copy)   NSString *videoLink;
@property (nonatomic, copy)   NSString *desc;
@property (nonatomic, copy)   NSArray <NSString *> *iosLinks;
@property (nonatomic, copy)   NSArray <NSString *> *androidLinks;
@property (nonatomic, copy)   NSArray <PCThumb *> *screenshots;
@property (nonatomic, strong) NSDate *updated_at;
@property (nonatomic, strong) NSDate *created_at;
@property (nonatomic, assign) NSInteger iosSize;
@property (nonatomic, assign) NSInteger androidSize;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger downloadsCount;
@property (nonatomic, assign) BOOL isLiked;


@end

@interface PCGameList : NSObject
 
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, copy)   NSArray <PCGame *> *docs;

@end

NS_ASSUME_NONNULL_END
