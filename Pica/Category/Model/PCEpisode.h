//
//  PCEpisode.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/*
 id = "5f6cc0f1eda62249b7e0663b";
 _id = "5f6cc0f1eda62249b7e0663b";
 title = "第11話";
 order = 4;
 updated_at = "2020-09-21T14:21:25.998Z";
 */
 
@interface PCEpisode : NSObject

@property (nonatomic, copy)   NSString  *episodeId;
@property (nonatomic, copy)   NSString  *title;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, strong) NSDate    *updated_at;

@end

@interface PCComicsEpisode : NSObject

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, copy)   NSArray <PCEpisode *> *docs;

//custom 用于图片详情
@property (nonatomic, copy)   NSString *comicsId;

@end

NS_ASSUME_NONNULL_END
