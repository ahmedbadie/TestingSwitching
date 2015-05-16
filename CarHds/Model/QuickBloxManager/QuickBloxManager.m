//
//  QuickBloxManager.m
//  CarHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "QuickBloxManager.h"
#import "MeetingHandler.h"

#define FIRST_NAME_JSON_KEY @"FirstName"
#define LAST_NAME_JSON_KEY @"LastName"

@implementation QuickBloxManager

#pragma mark - User Creation methods -

+(void)registerUserWithUsername:(NSString *)username andPassword:(NSString *)password andFirstName:(NSString *)firstName andLastName:(NSString *)lastName andEmail:(NSString *)email withCompletionHandler:(void (^)(APIResponse *))handler
{
    QBUUser* user = [QBUUser user];
    user.login = username;
    user.password = password;
    user.email = email;
    user.fullName = [NSString stringWithFormat:@"%@, %@",firstName,lastName];
    
    NSDictionary * customJsonObject = [NSDictionary dictionaryWithObjectsAndKeys:
                                       firstName,FIRST_NAME_JSON_KEY,
                                       lastName,LAST_NAME_JSON_KEY,
                                       nil];
    
    NSError * error;
    NSData* customData = [NSJSONSerialization dataWithJSONObject:customJsonObject
                                                         options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString * customDataText = [[NSString alloc] initWithData:customData encoding:NSUTF8StringEncoding];
    NSLog(@"customDataText %@",customDataText);
    user.customData = customDataText;
    
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        
        APIResponse* apiResponse =[APIResponse apiResponse];
        apiResponse.result = user;
        [MeetingHandler sharedInstance].qbUser = user;
        handler(apiResponse);
        
    } errorBlock:^(QBResponse *response) {
        
        APIResponse* apiResponse =[APIResponse apiResponse];
        apiResponse.error=response.error.error;
        handler(apiResponse);
        
    }];
}

//+(void)loginWithUser:(NSString *)username andPassword:(NSString *)password withCompletionHandler:(void (^)(APIResponse *))handler
//{
//
//
//    [QBRequest logInWithUserLogin:username password:password successBlock:^(QBResponse *response, QBUUser *user) {
//        APIResponse* apiResponse = [APIResponse apiResponse];
//        apiResponse.result = user;
//        QBUUser* userTemp = user;
//        [MeetingHandler sharedInstance].qbUser = userTemp;
//        handler(apiResponse);
//
//    } errorBlock:^(QBResponse *response) {
//        APIResponse* apiResponse = [APIResponse apiResponse];
//        apiResponse.error = response.error.error;
//        handler(apiResponse);
//    }];
//}
@end
