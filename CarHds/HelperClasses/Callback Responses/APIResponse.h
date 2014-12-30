//
//  APIResponse.h
//  CarHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIResponse : NSObject
@property(nonatomic,strong) NSError* error;
@property (nonatomic,strong) NSObject* result;

+(instancetype) apiResponse;
@end
