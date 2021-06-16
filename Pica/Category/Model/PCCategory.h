//
//  PCCategory.h
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCThumb.h"

NS_ASSUME_NONNULL_BEGIN
/*
 {
         "title": "援助嗶咔",
         "thumb": {
           "originalName": "help.jpg",
           "path": "help.jpg",
           "fileServer": "https://oc.woyeahgo.cf/static/"
         },
         "isWeb": true,
         "active": true,
         "link": "https://donate.woyeahgo.cf"
       }
 */
@interface PCCategory : NSObject

@property (nonatomic, copy)   NSString *categoryId;//_id
@property (nonatomic, copy)   NSString *title;
@property (nonatomic, copy)   NSString *link;
@property (nonatomic, copy)   NSString *desc;      //description
@property (nonatomic, strong) PCThumb *thumb;
@property (nonatomic, assign) BOOL isWeb;
@property (nonatomic, assign) BOOL active;

//custom
@property (nonatomic, assign) BOOL isCustom;
@property (nonatomic, copy)   NSString *controllerClass;

+ (PCCategory *)rankCategory;
+ (PCCategory *)randomCategory;
+ (PCCategory *)commentCategory;

@end

NS_ASSUME_NONNULL_END
