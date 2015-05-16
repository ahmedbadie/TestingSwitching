//
//  ErrorMapper.h
//  HRSystem
//
//  Created by Inova010 on 12/6/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/QBError.h>
@interface ErrorMapper : NSObject
@property (nonatomic,strong) NSMutableDictionary* errorDictionary;

+(NSString*) getErrorMessage:(NSError*) error;
+(NSString*) getQBErrorMessage:(QBError *)error;
@end
