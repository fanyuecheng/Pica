//
//  PCPicture.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PCThumb.h"

NS_ASSUME_NONNULL_BEGIN

/*
 _id = "5f6cc0f1eda62249b7e0669c";
 media = {
     path = "1d8abb45-8885-44f5-8490-398de83fd82d.jpg";
     originalName = "1.jpg";
     fileServer = "https://storage1.picacomic.com";
 };
 id = "5f6cc0f1eda62249b7e0669c";
 */

@class PCEpisode;
@interface PCPicture : NSObject

@property (nonatomic, copy)   NSString *pictureId;
@property (nonatomic, strong) PCThumb  *media;
@property (nonatomic, strong) UIImage  *image;

- (void)loadImage:(nullable void (^)(UIImage *image, NSError *error))finished;
- (void)cancelLoadImage;

@end

@interface
PCEpisodePicture : NSObject

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger pages;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, copy)   NSArray <PCPicture *> *docs;
@property (nonatomic, strong) PCEpisode *ep;
 
@end
//4903357  2cc6322b%2C1611637507%2Ccda26*71   597194c114aeef59678d9faf8176f05d


NS_ASSUME_NONNULL_END
