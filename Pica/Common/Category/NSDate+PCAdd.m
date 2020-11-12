//
//  NSDate+PCAdd.m
//  Pica
//
//  Created by fancy on 2020/11/10.
//  Copyright © 2020 fancy. All rights reserved.
//

#import "NSDate+PCAdd.h"

@implementation NSDate (PCAdd)

- (NSUInteger)pc_day {
    return [NSDate pc_day:self];
}

- (NSUInteger)pc_month {
    return [NSDate pc_month:self];
}

- (NSUInteger)pc_year {
    return [NSDate pc_year:self];
}

- (NSUInteger)pc_hour {
    return [NSDate pc_hour:self];
}

- (NSUInteger)pc_minute {
    return [NSDate pc_minute:self];
}

- (NSUInteger)pc_second {
    return [NSDate pc_second:self];
}

+ (NSUInteger)pc_day:(NSDate *)date {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:date] day];
}

+ (NSUInteger)pc_month:(NSDate *)date {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:date] month];
}

+ (NSUInteger)pc_year:(NSDate *)date {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date] year];
}

+ (NSUInteger)pc_hour:(NSDate *)date {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitHour fromDate:date] hour];
}

+ (NSUInteger)pc_minute:(NSDate *)date {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitMinute fromDate:date] minute];
}

+ (NSUInteger)pc_second:(NSDate *)date {
    return [[[NSCalendar currentCalendar] components:NSCalendarUnitSecond fromDate:date] second];
}

+ (NSString *)pc_stringWithDate:(NSDate *)date format:(NSString *)format {
    return [date pc_stringWithFormat:format];
}

- (NSString *)pc_stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:self];
}

+ (NSDate *)pc_dateWithString:(NSString *)dateString
                       format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter dateFromString:dateString];
}

- (NSString *)pc_timeInfo {
    return [NSDate pc_timeInfoWithDate:self];
}

+ (NSString *)pc_timeInfoWithDate:(NSDate *)date {
    return [self pc_timeInfoWithDateString:[self pc_stringWithDate:date format:@"yyyy-MM-dd HH:mm:ss"]];
}

+ (NSString *)pc_timeInfoWithDateString:(NSString *)dateString {
    NSDate *date = [self pc_dateWithString:dateString format:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *curDate = [NSDate date];
    NSTimeInterval time = -[date timeIntervalSinceDate:curDate];
    
    int month = (int)([curDate pc_month] - [date pc_month]);
    int year = (int)([curDate pc_year] - [date pc_year]);
    int day = (int)([curDate pc_day] - [date pc_day]);
    
    NSTimeInterval retTime = 1.0;
    if (time < 3600) { // 小于一小时
        retTime = time / 60;
        retTime = retTime <= 0.0 ? 1.0 : retTime;
        return [NSString stringWithFormat:@"%.0f分钟前", retTime];
    } else if (time < 3600 * 24) { // 小于一天，也就是今天
        retTime = time / 3600;
        retTime = retTime <= 0.0 ? 1.0 : retTime;
        return [NSString stringWithFormat:@"%.0f小时前", retTime];
    } else if (time < 3600 * 24 * 2) {
        return @"昨天";
    }
    // 第一个条件是同年，且相隔时间在一个月内
    // 第二个条件是隔年，对于隔年，只能是去年12月与今年1月这种情况
    else if ((abs(year) == 0 && abs(month) <= 1)
             || (abs(year) == 1 && [curDate pc_month] == 1 && [date pc_month] == 12)) {
        int retDay = 0;
        if (year == 0) { // 同年
            if (month == 0) { // 同月
                retDay = day;
            }
        }
        
        if (retDay <= 0) {
            // 获取发布日期中，该月有多少天
            int totalDays = (int)[self pc_daysInMonth:date month:[date pc_month]];
            
            // 当前天数 + （发布日期月中的总天数-发布日期月中发布日，即等于距离今天的天数）
            retDay = (int)[curDate pc_day] + (totalDays - (int)[date pc_day]);
        }
        
        return [NSString stringWithFormat:@"%d天前", (abs)(retDay)];
    } else  {
        if (abs(year) <= 1) {
            if (year == 0) { // 同年
                return [NSString stringWithFormat:@"%d个月前", abs(month)];
            }
            
            // 隔年
            int month = (int)[curDate pc_month];
            int preMonth = (int)[date pc_month];
            if (month == 12 && preMonth == 12) {// 隔年，但同月，就作为满一年来计算
                return @"1年前";
            }
            return [NSString stringWithFormat:@"%d个月前", (abs)(12 - preMonth + month)];
        }
        
        return [NSString stringWithFormat:@"%d年前", abs(year)];
    }
    
    return @"1小时前";
}

- (NSUInteger)pc_daysInMonth:(NSUInteger)month {
    return [NSDate pc_daysInMonth:self month:month];
}

+ (NSUInteger)pc_daysInMonth:(NSDate *)date month:(NSUInteger)month {
    switch (month) {
        case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            return 31;
        case 2:
            return [date pc_isLeapYear] ? 29 : 28;
    }
    return 30;
}

- (BOOL)pc_isLeapYear {
    return [NSDate pc_isLeapYear:self];
}

+ (BOOL)pc_isLeapYear:(NSDate *)date {
    NSUInteger year = [date pc_year];
    if ((year % 4  == 0 && year % 100 != 0) || year % 400 == 0) {
        return YES;
    }
    return NO;
}

@end
