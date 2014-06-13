//
//  NSDate+Helper.h
//  TestConstrains
//
//  Created by Diego Lima on 04/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)

+ (NSDate *)todayWithHours:(NSInteger)hour;
- (NSString *)convertDateToString;
- (NSDate *)convertStringToDate:(NSString *)strDate;
@end
