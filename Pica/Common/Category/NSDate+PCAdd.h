//
//  NSDate+PCAdd.h
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (PCAdd)

- (NSUInteger)pc_day;
- (NSUInteger)pc_month;
- (NSUInteger)pc_year;
- (NSUInteger)pc_hour;
- (NSUInteger)pc_minute;
- (NSUInteger)pc_second;
+ (NSUInteger)pc_day:(NSDate *)date;
+ (NSUInteger)pc_month:(NSDate *)date;
+ (NSUInteger)pc_year:(NSDate *)date;
+ (NSUInteger)pc_hour:(NSDate *)date;
+ (NSUInteger)pc_minute:(NSDate *)date;
+ (NSUInteger)pc_second:(NSDate *)date;

+ (NSDate *)pc_dateWithString:(NSString *)dateString format:(NSString *)format;

+ (NSString *)pc_stringWithDate:(NSDate *)date format:(NSString *)format;

- (NSString *)pc_stringWithFormat:(NSString *)format;

- (NSString *)pc_timeInfo;

+ (NSString *)pc_timeInfoWithDate:(NSDate *)date;

+ (NSString *)pc_timeInfoWithDateString:(NSString *)dateString;

- (NSUInteger)pc_daysInMonth:(NSUInteger)month;

+ (NSUInteger)pc_daysInMonth:(NSDate *)date month:(NSUInteger)month;

- (BOOL)pc_isLeapYear;

+ (BOOL)pc_isLeapYear:(NSDate *)date;


@end

NS_ASSUME_NONNULL_END
