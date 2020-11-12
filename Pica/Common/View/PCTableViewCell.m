//
//  PCTableViewCell.m
//  Pica
//
//  Created by fancy on 2020/11/9.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "PCTableViewCell.h"

@implementation PCTableViewCell

- (void)didInitializeWithStyle:(UITableViewCellStyle)style {
    [super didInitializeWithStyle:style];
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = UIColorMake(248, 248, 248);
    self.selectedBackgroundView = selectedBackgroundView;
}

@end
