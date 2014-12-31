//
//  MeetingHandler.h
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Quickblox/Quickblox.h>
#import "JsonMessageParser.h"
@protocol MeetingHandlerDelegate <NSObject>

-(void) didReciveMessages:(NSArray*) msgs;
-(void) didConnectToRoom:(QBChatRoom*) chatRoom;

@end
@interface MeetingHandler : NSObject<QBChatDelegate,QBActionStatusDelegate>

@property(nonatomic,strong) QBChatDialog* chatDialog;
@property (nonatomic,strong) QBUUser* qbUser;
@property (nonatomic,strong) QBChatRoom* chatRoom;
@property (nonatomic,strong) UIViewController<MeetingHandlerDelegate>* delegate;
@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic) BOOL isJoinedToChat;

+(instancetype) sharedInstance;

-(void) connectToChatDialog:(QBChatDialog*) chatDialog;
-(void) sendMessage:(NSString*)msg toChatRoom:(QBChatRoom*) chatRoom;
@end
