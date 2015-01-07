//
//  Utilities.m
//  CarHds
//
//  Created by Inova010 on 1/7/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

static NSDate* maxInterval;


+(BOOL)withinRoomLife:(NSDate *)startDate
{
    NSDate *endDate = [NSDate date];
    NSLog(@"%@",endDate);
    NSLog(@"%@",startDate);
    if(startDate==nil)
    {
        return NO;
    }
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorianCalendar components: NSSecondCalendarUnit
                                                        fromDate:startDate
                                                          toDate:endDate
                                                         options:0];
    if(components.second > MAX_TIME_INTERVAL)
    {
        return NO;
    }
    return YES;
}


@end
