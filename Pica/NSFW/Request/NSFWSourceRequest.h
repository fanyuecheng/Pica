//
//  NSFWSourceRequest.h
//  Pica
//
//  Created by Fancy on 2022/2/11.
//  Copyright © 2022 fancy. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFWSourceRequest : YTKRequest

- (BOOL)downloaded;
- (NSString *)rootDirectory;

@end

NS_ASSUME_NONNULL_END
