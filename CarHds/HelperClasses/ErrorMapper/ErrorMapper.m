//
//  ErrorMapper.m
//  HRSystem
//
//  Created by Inova010 on 12/6/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "ErrorMapper.h"

@implementation ErrorMapper


+ (id)sharedManager {
    static ErrorMapper *errorMapper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        errorMapper = [[self alloc] init];
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ErrorMessages" ofType:@"plist"];
        errorMapper.errorDictionary= [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        if(errorMapper.errorDictionary==nil)
            errorMapper.errorDictionary = [NSMutableDictionary dictionary];

    });
    return errorMapper;
}
+(NSString *)getErrorMessage:(NSError *)error
{
    
    NSString* key = [NSString stringWithFormat:@"%@:%ld",error.domain,(long)error.code];
    ErrorMapper* mapper = [ErrorMapper sharedManager];
    NSString* msg = [mapper.errorDictionary objectForKey:key];

    if(msg)
        return msg;
    msg= [error.userInfo objectForKey:@"error"];
    if(msg)
        return msg;
    return [error description];
}
@end
