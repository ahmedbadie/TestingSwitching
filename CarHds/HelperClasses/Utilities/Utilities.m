//
//  Utilities.m
//  CarHds
//
//  Created by Inova010 on 1/7/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@implementation Utilities

static NSDate* maxInterval;


+(BOOL)withinRoomLife:(NSDate *)startDate
{
    NSDate *endDate = [NSDate date];
//    NSLog(@"withinRoomLife endDate %@",endDate);
//    NSLog(@"withinRoomLife startDate %@",startDate);
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

+ (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

+(void)saveRememberMe:(BOOL)rememberMe{
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:[NSNumber numberWithBool:rememberMe] forKey:@"rememberMe"];
    [pref synchronize];
}

+(BOOL)loadRememberMe{
    NSNumber * rememberMe;
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    rememberMe=[prefs objectForKey:@"rememberMe"];
    
    if(rememberMe != nil){
        return  rememberMe.boolValue;
    }
    
    return  false;
}

@end
