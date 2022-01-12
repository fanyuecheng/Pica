//
//  PCPicture.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCPicture.h"
#import "PCDefineHeader.h"
#import "PCVendorHeader.h"
#import "UIImage+PCAdd.h"
#import "PCImageSizeCache.h"

@interface PCPicture ()

@property (nonatomic, strong) SDWebImageCombinedOperation *operation;

@end

@implementation PCPicture

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"pictureId" : @[@"_id", @"id"]};
}

- (void)loadImage:(void (^)(UIImage *image, NSError *error))finished {
    @weakify(self)
    self.operation = [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.media.imageURL] options:SDWebImageScaleDownLargeImages context:nil progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finishe, NSURL * _Nullable imageURL) {
        @strongify(self)
        if (image) {
            [kPCImageSizeCache storeImageSize:image.size forKey:self.media.imageURL];
            self.image = image;
            !finished ? : finished(image, nil);
        } else {
            !finished ? : finished(nil, error);
        }
    }];
}

- (void)cancelLoadImage {
    [self.operation cancel];
    self.operation = nil;
}
 
@end

@implementation PCEpisodePicture

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"docs" : @"PCPicture"};
}

@end

