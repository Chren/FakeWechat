//
//  ORDateUtil.m
//  ORead
//
//  Created by noname on 14-9-2.
//  Copyright (c) 2014年 oread. All rights reserved.
//

#import "ORDateUtil.h"
#import <CocoaSecurity/CocoaSecurity.h>

@implementation ORDateUtil

+(NSString *)formatDateForMessageCellWithTimeInterval:(long long)aTimeInterval
{
    NSString *dateString = nil;
    
    time_t intervalInSecond = aTimeInterval;
    time_t ltime;
    time(&ltime);
    
    struct tm today;
    localtime_r(&ltime, &today);
    struct tm nowdate;
    localtime_r(&intervalInSecond, &nowdate);
    struct tm yesterday;
    localtime_r(&ltime, &yesterday);
    yesterday.tm_mday -= 1;
    struct tm theDayBeforeYesterday;
    localtime_r(&ltime, &theDayBeforeYesterday);
    theDayBeforeYesterday.tm_mday -= 2;
    
	if(today.tm_year == nowdate.tm_year && today.tm_mday == nowdate.tm_mday && today.tm_mon == nowdate.tm_mon)//今天
	{
        char s[100];
        strftime(s,sizeof(s),"%R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
	}
	else if((yesterday.tm_year == nowdate.tm_year && yesterday.tm_mon == nowdate.tm_mon && yesterday.tm_mday  == nowdate.tm_mday))//昨天
	{
        char s[100];
        strftime(s,sizeof(s),"昨天 %R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
	}else if((theDayBeforeYesterday.tm_year == nowdate.tm_year && theDayBeforeYesterday.tm_mon == nowdate.tm_mon && theDayBeforeYesterday.tm_mday  == nowdate.tm_mday))//前天
	{
        char s[100];
        strftime(s,sizeof(s),"前天 %R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
	}
	else if(today.tm_year == nowdate.tm_year)//今年内
	{
        char s[100];
        strftime(s,sizeof(s),"%m月%d日", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
	}
	else//其他年份
	{
        char s[100];
        strftime(s,sizeof(s),"%y年%m月%d日", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
	}
    
    return dateString;
}



+ (NSString *)formatDateForMessageCellMinutesWithTimeInterval:(long long)aTimeInterval
{
    NSString *dateString = nil;
    
    time_t intervalInSecond = aTimeInterval;
    time_t ltime;
    time(&ltime);
    
    struct tm today;
    localtime_r(&ltime, &today);
    struct tm nowdate;
    localtime_r(&intervalInSecond, &nowdate);
    struct tm yesterday;
    localtime_r(&ltime, &yesterday);
    yesterday.tm_mday -= 1;
    struct tm theDayBeforeYesterday;
    localtime_r(&ltime, &theDayBeforeYesterday);
    theDayBeforeYesterday.tm_mday -= 2;
    
    if(today.tm_year == nowdate.tm_year && today.tm_mday == nowdate.tm_mday && today.tm_mon == nowdate.tm_mon)//今天
    {
        char s[100];
        strftime(s,sizeof(s),"%R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
    }
    else if((yesterday.tm_year == nowdate.tm_year && yesterday.tm_mon == nowdate.tm_mon && yesterday.tm_mday  == nowdate.tm_mday))//昨天
    {
        char s[100];
        strftime(s,sizeof(s),"昨天 %R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
    }else if((theDayBeforeYesterday.tm_year == nowdate.tm_year && theDayBeforeYesterday.tm_mon == nowdate.tm_mon && theDayBeforeYesterday.tm_mday  == nowdate.tm_mday))//前天
    {
        char s[100];
        strftime(s,sizeof(s),"前天 %R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
    }
    else if(today.tm_year == nowdate.tm_year)//今年内
    {
        char s[100];
        strftime(s,sizeof(s),"%m月%d %R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
    }
    else//其他年份
    {
        char s[100];
        strftime(s,sizeof(s),"%y年%m月%d %R", &nowdate);
        dateString = [NSString stringWithCString:s encoding:NSUTF8StringEncoding];
    }
    
    return dateString;
}


+ (NSString *)formatDurationForTimeInterval:(long long)aTimeInterval
{
    NSInteger ti = (NSInteger)aTimeInterval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    NSString *formatedString = nil;
    if (hours>0) {
        formatedString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
    } else {
        formatedString = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    }
    return formatedString;
}

+ (NSString *)formatedDateForBirthdayWithTimeInterval:(long long)aTimeInterval
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [formater stringFromDate:[NSDate dateWithTimeIntervalSince1970:aTimeInterval]];
    return dateString;
}

+(NSString *)uniqueStringFromDate
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    NSString *dateString = [formater stringFromDate:[NSDate date]];
    NSString *resultString = [CocoaSecurity md5:dateString].hexLower;
    return resultString;
}

+ (NSArray *)dateAndTimeStringFromDate:(long long)aTimeInterval
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    
    [formater setDateFormat:@"MM.dd"];
    NSString *dateString = [formater stringFromDate:[NSDate dateWithTimeIntervalSince1970:aTimeInterval / 100]];
    
     [formater setDateFormat:@"HH:mm"];
      NSString *timeString = [formater stringFromDate:[NSDate dateWithTimeIntervalSince1970:aTimeInterval / 100]];
    
    NSArray *array = [NSArray arrayWithObjects:dateString,timeString, nil];
    return array;
}
@end

@implementation NSDate(Custom)
- (BOOL)isSameDayWithDate:(NSDate*)aDate {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:aDate];
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

@end
