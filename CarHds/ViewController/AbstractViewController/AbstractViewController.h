//
//  AbstractViewController.h
//  CaRHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "QuickBloxManager.h"
#import "ChatService.h"
#import "MeetingHandler.h"
#import "JsonMessageParser.h"

#define UIDeviceOrientationIsPortrait(orientation) ((orientation) == UIDeviceOrientationPortrait || (orientation) == UIDeviceOrientationPortraitUpsideDown)
#define UIDeviceOrientationIsLandscape(orientation) ((orientation) == UIDeviceOrientationLandscapeLeft || (orientation) == UIDeviceOrientationLandscapeRight)
#define IS_IPAD  UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad 
@interface AbstractViewController : UIViewController< MeetingHandlerDelegate,JsonMessageParserDelegate,UITextFieldDelegate>
@property(nonatomic,retain) QBUUser* user;
@property(nonatomic,retain) QBChatDialog* chatDialog;
@property(nonatomic,retain) MBProgressHUD* hud;
-(void) warnUserWithMessage:(NSString*) msg;
-(BOOL) NSStringIsValidEmail:(NSString *)checkString;
-(void) setLandscapeMode;
-(void) setPortaitMode;
@end
