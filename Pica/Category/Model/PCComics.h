//
//  PCComics.h
//  Pica
//
//  Created by fancy on 2020/11/9.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCUser.h"

NS_ASSUME_NONNULL_BEGIN
/*
 {
     categories = (
         "Cosplay"
     );
     allowDownload = 1;
     totalLikes = 455;
     totalViews = 34567;
     title = "Miku Halloween Devil cosplay by Hidori Rose";
     pagesCount = 26;
     tags = (
         "初音",
         "COSPLAY"
     );
     chineseTeam = "";
     finished = 0;
     updated_at = "2020-11-07T17:33:44.982Z";
     likesCount = 455;
     _id = "5fa6da787193765a84db5261";
     commentsCount = 21;
     epsCount = 1;
     _creator = {
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
     };
     isFavourite = 0;
     isLiked = 0;
     thumb = {
         path = "tobeimg/EC4QpEjzIy7pPwrY43xBz6PoJKXwGpbn228W1GGMNPs/fill/300/400/sm/0/aHR0cHM6Ly9zdG9yYWdlMS5waWNhY29taWMuY29tL3N0YXRpYy9iM2Q1ZTE3MC1kMTY1LTQwYjctODM3Zi03YTg5ZGZmZjY3ZjIuanBn.jpg";
         originalName = "Miku_Halloween_Devil_cosplay_by_Hidori_Rose_11.jpg";
         fileServer = "https://storage1.picacomic.com";
     };
     viewsCount = 34567;
     created_at = "2020-11-07T12:48:32.393Z";
     allowComment = 1;
     author = "Hidori Rose";
     description = "初音未来COS";
 };
 */
 
@interface PCComics : NSObject

@property (nonatomic, copy)   NSString  *comicsId; //id || _id
@property (nonatomic, copy)   NSString  *author;
@property (nonatomic, copy)   NSString  *title;
@property (nonatomic, copy)   NSString  *desc;     //description
@property (nonatomic, copy)   NSString  *chineseTeam;
@property (nonatomic, assign) NSInteger totalLikes;
@property (nonatomic, assign) NSInteger likesCount;
@property (nonatomic, assign) NSInteger pagesCount;
@property (nonatomic, assign) NSInteger viewsCount;
@property (nonatomic, assign) NSInteger commentsCount;
@property (nonatomic, assign) NSInteger epsCount;
@property (nonatomic, assign) NSInteger totalViews;
@property (nonatomic, assign) BOOL      finished;
@property (nonatomic, assign) BOOL      allowDownload;
@property (nonatomic, assign) BOOL      isFavourite;
@property (nonatomic, assign) BOOL      isLiked;
@property (nonatomic, assign) BOOL      allowComment;
@property (nonatomic, copy)   NSArray   <NSString *> *categories;
@property (nonatomic, copy)   NSArray   <NSString *> *tags;
@property (nonatomic, strong) NSDate    *created_at;
@property (nonatomic, strong) NSDate    *updated_at;
@property (nonatomic, strong) PCUser    *creator;
@property (nonatomic, strong) PCThumb   *thumb;

//rank
@property (nonatomic, assign) NSInteger leaderboardCount;

@end

@interface PCComicsList : NSObject
 
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, copy)   NSArray <PCComics *> *docs;

@end

NS_ASSUME_NONNULL_END
 
