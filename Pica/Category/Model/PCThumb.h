//
//  PCThumb.h
//  Pica
//
//  Created by fancy on 2020/11/3.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 "originalName": "help.jpg",
 "path": "help.jpg",
 "fileServer": "https://oc.woyeahgo.cf/static/"
 */

@interface PCThumb : NSObject

@property (nonatomic, copy) NSString *originalName;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *fileServer;

//图片链接 fileServer + "/static/" + path构成
@property (nonatomic, copy, readonly) NSString *imageURL;

@end

NS_ASSUME_NONNULL_END
