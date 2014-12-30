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
@interface AbstractViewController : UIViewController< MeetingHandlerDelegate,JsonMessageParserDelegate>
@property(nonatomic,retain) QBUUser* user;
@property(nonatomic,retain) QBChatDialog* chatDialog;
@property(nonatomic,retain) MBProgressHUD* hud;
-(void) warnUserWithMessage:(NSString*) msg;
@property (nonatomic,strong) MeetingHandler* handler;
@end
