//
//  PCContentCell.m
//  Pica
//
//  Created by Fancy on 2021/6/28.
//  Copyright © 2021 fancy. All rights reserved.
//

#import "PCContentCell.h"

@implementation PCContentCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.font = UIFontMake(14);
    self.textLabel.numberOfLines = 0;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, [self.textLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 30, CGFLOAT_MAX)].height + 30);
}

@end
