//
//  NSDate+Helper.m
//  TestConstrains
//
//  Created by Diego Lima on 04/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "NSDate+Helper.h"
#include <time.h>

//static NSDateFormatter *format = [[NSDateFormatter alloc] init];

@implementation NSDate (Helper)

+ (NSDate *)todayWithHours:(NSInteger)hour {
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    [components setHour:hour];
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)convertStringToDate:(NSString *)strDate {
    if (!strDate) {
        return nil;
    }
    
    struct tm tm;
    time_t t;
    
    strptime([strDate cStringUsingEncoding:NSUTF8StringEncoding], "%d/%m/%Y %H:%M", &tm);
    tm.tm_isdst = -1;
    t = mktime(&tm);
    
    return [NSDate dateWithTimeIntervalSince1970:t + [[NSTimeZone localTimeZone] secondsFromGMT]];
}


- (NSString *)convertDateToString {
    struct tm *timeinfo;
    char buffer[80];
    
    time_t rawtime = [self timeIntervalSince1970] - [[NSTimeZone localTimeZone] secondsFromGMT];
    timeinfo = localtime(&rawtime);
    
    strftime(buffer, 80, "%d/%m/%Y %H:%M", timeinfo);
    
    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

@end
