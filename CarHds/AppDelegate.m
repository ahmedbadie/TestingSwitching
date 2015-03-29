//
//  AppDelegate.m
//  CarHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (nonatomic) BOOL loggedIn;
@end

@implementation AppDelegate

@synthesize loggedIn;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    //
    loggedIn = NO;
    [QBApplication sharedApplication].applicationId = QUICK_BLOX_APP_ID;
    [QBConnection registerServiceKey:QUICK_BLOX_SERVICE_KEY];
    [QBConnection registerServiceSecret:QUICK_BLOX_SERVICE_SECRET];
    [QBSettings setAccountKey:QUICK_BLOX_ACCOUNT_KEY];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:USER_ID_KEY];
    [defaults removeObjectForKey:USER_PASSWORD_KEY];
#ifdef DEV
    [Instabug startWithToken:INSTABUG_APP_TOKEN captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventShake];
#else
    [Instabug startWithToken:INSTABUG_APP_TOKEN captureSource:IBGCaptureSourceUIKit invocationEvent:IBGInvocationEventNone];
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    loggedIn = [[QBChat instance] isLoggedIn];
//    [[QBChat instance]logout];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSUserDefaults* defualts = [NSUserDefaults standardUserDefaults];
    if([defualts objectForKey:USER_ID_KEY] !=nil && [defualts objectForKey:USER_PASSWORD_KEY]!=nil)
    {
        QBUUser* user = [QBUUser new];
        user.ID = [[defualts objectForKey:USER_ID_KEY] unsignedIntegerValue];
        user.password = [defualts objectForKey:USER_PASSWORD_KEY];
        [[ChatService instance] loginWithUser:user completionBlock:^{
        
            if([MeetingHandler sharedInstance].chatDialog!=nil)
            {
                QBChatDialog* chatDialog  = [MeetingHandler sharedInstance].chatDialog;
                [[MeetingHandler sharedInstance] connectToChatDialog:chatDialog];
                }
        }];
        
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSUserDefaults* defualts = [NSUserDefaults standardUserDefaults];
    if([defualts objectForKey:USER_ID_KEY] !=nil && [defualts objectForKey:USER_PASSWORD_KEY]!=nil)
    {
        QBUUser* user = [QBUUser new];
        user.ID = [[defualts objectForKey:USER_ID_KEY] unsignedIntegerValue];
        user.password = [defualts objectForKey:USER_PASSWORD_KEY];
        [[ChatService instance] loginWithUser:user completionBlock:^{
            
            if([MeetingHandler sharedInstance].chatDialog!=nil)
            {
//                QBChatDialog* chatDialog  = [MeetingHandler sharedInstance].chatDialog;
//                [MeetingHandler sharedInstance].terminate = YES;
//                [[MeetingHandler sharedInstance] connectToChatDialog:chatDialog];

                [[MeetingHandler sharedInstance] leaveRoom:YES];
            }
        }];
        
    }

}

@end
