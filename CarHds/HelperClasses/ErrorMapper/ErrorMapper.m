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
+(NSString*) removeExtrasFrom:(NSString*) string
{
    string = [ string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [ string stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    string = [ string stringByReplacingOccurrencesOfString:@")" withString:@""];
    string = [ string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    return string;
}
+(NSString *)getErrorMessage:(NSError *)error
{
    
    NSString* key = [NSString stringWithFormat:@"%@:%d",error.domain,error.code];
    if([error.userInfo objectForKey:@"NSLocalizedRecoverySuggestion"])
    {
        key = [error.userInfo objectForKey:@"NSLocalizedRecoverySuggestion"];
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:[key dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSString* msgFromDictionary = @"";
        NSDictionary* errorsDictionary = [dictionary objectForKey:@"errors"];
        NSArray* errors = [errorsDictionary allKeys];
        BOOL addLine = NO;
        for (NSString* i  in errors) {
            NSArray* array = [NSArray arrayWithArray:[errorsDictionary objectForKey:i]];
            msgFromDictionary = [msgFromDictionary stringByAppendingString:[NSString stringWithFormat:@"%@%@ %@",addLine? @"\n":@"" ,i,[array firstObject]]];
            addLine = YES;
        }
        
        return msgFromDictionary;

    }
    ErrorMapper* mapper = [ErrorMapper sharedManager];
    NSString* msg = [mapper.errorDictionary objectForKey:key];
    
    
    if(msg)
        return msg;
    msg= [error.userInfo objectForKey:@"error"];
    if(msg)
        return msg;
    return [error description];
}

+(NSString *)getQBErrorMessage:(QBError *)error
{
    NSString* string = @"";
    NSDictionary* dictionary = error.reasons;
    
    NSArray* keys = [dictionary allKeys];
    
    for(NSString* key in keys)
    {
        NSArray* array = [dictionary objectForKey:key];
        string= [string stringByAppendingString:[array firstObject]];
        
    }
    if(string.length ==0)
    {
        string = DESC(error.error);
    }
    
    return string;
}
@end
