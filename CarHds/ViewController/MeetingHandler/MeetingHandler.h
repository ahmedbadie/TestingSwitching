//
//  MeetingHandler.h
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JsonMessageParser.h"
#import <Quickblox/QBChatRoom.h>
#import <Quickblox/QBUUser.h>
#import <Quickblox/QBChatDialog.h>
#import <Quickblox/QBCoreDelegates.h>

@protocol MeetingHandlerDelegate <NSObject>

-(void) didReciveMessages:(NSArray*) msgs;
-(void) didConnectToRoom:(QBChatRoom*) chatRoom;
-(void) didLogOut;
@end
@interface MeetingHandler : NSObject<QBActionStatusDelegate>

@property (nonatomic) BOOL terminate;
@property(nonatomic,strong) QBChatDialog* chatDialog;
@property (nonatomic,strong) QBUUser* qbUser;
@property (nonatomic,strong) QBChatRoom* chatRoom;
@property (nonatomic,strong) NSString* hostname;
@property (nonatomic,strong) UIViewController<MeetingHandlerDelegate>* delegate;
@property (nonatomic) BOOL isLoggedIn;
@property (nonatomic) BOOL isJoinedToChat;
@property (nonatomic) BOOL logOut;
@property (nonatomic,strong) NSString* logOutmsgID;
+(instancetype) sharedInstance;

-(void) connectToChatDialog:(QBChatDialog*) chatDialog;
-(void) sendMessage:(NSString*)msg toChatRoom:(QBChatRoom*) chatRoom save:(BOOL) save;
-(void) leaveRoom:(BOOL) write;
-(void) closeRoom;


- (void)chatDidReceiveMessage:(QBChatMessage *)message;
- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomJID;
@end
