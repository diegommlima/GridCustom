//
//  NSDate+Helper.m
//  TestConstrains
//
//  Created by Diego Lima on 04/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NSDate+Helper.h"

@implementation NSDate (Helper)

+ (NSDate *)todayWithHours:(NSInteger)hour {
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:hour];
    
    return [calendar dateFromComponents:components];;
}

+ (NSString *)convertDateToString:(NSDate *)date {
    
    if (!date)
        return nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd/MM/yyyy hh:mm"];
    return [formatter stringFromDate:date];
}

+ (NSDate *)convertStringToDate:(NSString *)strDate {
    
    if (!strDate || strDate.length < 1)
        return nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"dd/MM/yyyy hh:mm"];
    return [formatter dateFromString:strDate];
}

@end
