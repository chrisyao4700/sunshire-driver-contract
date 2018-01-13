//
//  CYFunctionSet.h
//  FortuneLinkAdmin
//
//  Created by 姚远 on 4/19/17.
//  Copyright © 2017 SunshireShuttle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYFunctionSet : NSObject
+(NSNumber *) convertStringToNumber:(NSString *) str;


+(NSDate *) getDateFromTime:(NSDate *) org;
+(NSString *) urlEncode:(NSString *) org;
+(NSDate *) convertDateFromYearString:(NSString *) str;

+(NSDate *) converUTCDateStringToDate:(NSString *) utcStr;
+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time;
+ (NSDate *)combineFormatDate:(NSDate *)date withTime:(NSDate *)time;
+(NSString *) convertTimeToHourMinuteSecond:(NSDate *) date;
+(NSDate *)getFirstDayOfTheWeekFromDate:(NSDate *)givenDate;



+(NSDate *) getFirstDayOfTheMonthFromDate:(NSDate *) givenDate;
+(NSString *) convertDateToFormatString:(NSDate *) aDate;
+(NSString *) convertDateToShortStr:(NSDate *) aDate;
+(NSDate *) convertStringToDate:(NSString *) str;
+(NSString *) convertDateToString:(NSDate *) aDate;
+(NSString *) convertDoubleToString:(double) douNum;
+(NSString *) convertDateToYearString:(NSDate *) aDate;
+(NSString *) convertDateToConstantString:(NSDate *)aDate;

+(NSDate *) convertDateFromTwinString:(NSString *) str;
+(NSDate *) convertDateFromThribleString:(NSString *) str;
+(NSString *) convertStringToURLString:(NSString *) orgString;
+ (NSString *) md5:(NSString *) input;
+(NSDictionary*)stripNulls:(NSDictionary*)dict;
+(void) callGoogleMapWithDestination:(NSString *) strAddress
                forCompletionHandler:(void (^)(BOOL success)) handler
                      forFailHandler:(void(^)(void)) fail_handler;
@end
