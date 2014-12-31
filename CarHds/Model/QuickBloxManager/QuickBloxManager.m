//
//  QuickBloxManager.m
//  CarHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "QuickBloxManager.h"
#import "MeetingHandler.h"
@implementation QuickBloxManager

#pragma mark - User Creation methods -

+(void)registerUserWithUsername:(NSString *)username andPassword:(NSString *)password withCompletionHandler:(void (^)(APIResponse *))handler
{
    QBUUser* user = [QBUUser user];
    user.login = username;
    user.password = password;
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
//        if(response.status == QBResponseStatusCodeAccepted){
        APIResponse* apiResponse =[APIResponse apiResponse];

        apiResponse.result = user;
//    }else{
//                apiResponse.error = [NSError errorWithDomain:@"" code:response.status userInfo:nil];
//            }
        [MeetingHandler sharedInstance].qbUser = user;
        handler(apiResponse);
    } errorBlock:^(QBResponse *response) {
        APIResponse* apiResponse =[APIResponse apiResponse];

        apiResponse.error=response.error.error;
        handler(apiResponse);
    }];
}

+(void)loginWithUser:(NSString *)username andPassword:(NSString *)password withCompletionHandler:(void (^)(APIResponse *))handler
{
    
    
    [QBRequest logInWithUserLogin:username password:password successBlock:^(QBResponse *response, QBUUser *user) {
        APIResponse* apiResponse = [APIResponse apiResponse];
        apiResponse.result = user;
        QBUUser* userTemp = user;
        [MeetingHandler sharedInstance].qbUser = userTemp;
        handler(apiResponse);
        
    } errorBlock:^(QBResponse *response) {
        APIResponse* apiResponse = [APIResponse apiResponse];
        apiResponse.error = response.error.error;
        handler(apiResponse);
    }];
}
@end
