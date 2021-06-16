//
//  PCSearchRecordView.h
//  Pica
//
//  Created by Fancy on 2021/5/31.
//  Copyright © 2021 fancy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PCSearchRecordView : UITableView

- (void)saveSearchKey:(NSString *)key;
- (NSInteger)recordCount;

@end

NS_ASSUME_NONNULL_END
