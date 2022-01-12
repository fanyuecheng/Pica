//
//  PCComment.m
//  Pica
//
//  Created by fancy on 2020/11/11.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCComment.h"

@implementation PCComment

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"commentId" : @"_id",
             @"user" : @"_user",
             @"comic" : @[@"_comic._id", @"_comic"],
             @"game" : @[@"_game._id", @"_game"]};
}

+ (PCComment *)commentWithContent:(NSString *)content isChild:(BOOL)isChild {
    PCComment *comment = [[PCComment alloc] init];
    comment.content = content;
    comment.created_at = [NSDate date];
    comment.user = [PCUser localUser];
    comment.isChild = isChild;
    comment.commentId = @"pc_comment_id_test_temp";
    return comment;
}
 
@end


@implementation PCComicComment

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"page" : @"comments.page",
             @"pages" : @"comments.pages",
             @"total" : @"comments.total",
             @"limit" : @"comments.limit",
             @"docs" : @"comments.docs"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"topComments" : @"PCComment",
             @"docs" : @"PCComment"};
}

@end
