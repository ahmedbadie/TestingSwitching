//
//  QuickBloxManager.h
//  CarHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIResponse.h"
@interface QuickBloxManager : NSObject

//+(void) loginWithUser:(NSString*) username andPassword:(NSString*) password withCompletionHandler:(void(^) (APIResponse* response))handler;

+(void)registerUserWithUsername:(NSString *)username andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmail:(NSString *)email withCompletionHandler:(void (^)(APIResponse *))handler;


@end
