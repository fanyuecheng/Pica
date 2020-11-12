//
//  PCUser.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCUser.h"

@implementation PCUser

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"userId" : @[@"_id", @"id"],
             @"desc" : @"description"};
}

@end
