//
//  PCPicture.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCPicture.h"
#import "PCVendorHeader.h"
#import "UIImage+PCAdd.h"

@implementation PCPicture

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"pictureId" : @[@"_id", @"id"]};
}

- (CGSize)preferSize {
    if (self.image) {
        if (CGSizeIsEmpty(_preferSize)) {
            CGSize size = self.image.size;
            _preferSize = CGSizeMake(SCREEN_WIDTH, floorf(SCREEN_WIDTH * size.height / size.width));
        }
        return _preferSize;
    } else {
        return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH);
    }
}
 
@end

@implementation PCEpisodePicture

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"docs" : @"PCPicture"};
}

@end

