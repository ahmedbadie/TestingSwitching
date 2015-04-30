//
//  MeetingHandler.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "MeetingHandler.h"
#import "ChatService.h"
@implementation MeetingHandler



static MeetingHandler* handler;

+(instancetype)sharedInstance
{
    if(handler==nil)
    {
        handler = [[MeetingHandler alloc]init];
        handler.logOut = NO;
    }
    return handler;
}
-(void)connectToChatDialog:(QBChatDialog *)chatDialog
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
    
    // Join room
    QBChatRoom* room = self.chatDialog.chatRoom;
    self.chatRoom = room;
    [QBChat instance].delegate = [ChatService instance];
    if(self.chatDialog.type != QBChatDialogTypePrivate){
        [[ChatService instance] joinRoom:self.chatRoom completionBlock:^(QBChatRoom * room) {
            if(self.terminate)
            {
                [[MeetingHandler sharedInstance] leaveRoom:YES];
                [[QBChat instance]logout];
            }else{
            [self chatRoomDidEnter:self.chatRoom];
            }
            }];

    }
    
    // get messages history
    [QBChat messagesWithDialogID:self.chatDialog.ID extendedRequest:nil delegate:self];

}


#pragma mark - Chat Notification Methods -

- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
    
    QBChatMessage *message = notification.userInfo[kMessage];
    if(message.senderID != self.chatDialog.recipientID){
        return;
    }
    
    // save message
    [self.delegate didReciveMessages:@[message]];
}

- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *roomJID = notification.userInfo[kRoomJID];
    
    
//    if(self.logOut && [message.ID isEqualToString:self.logOutmsgID])
//    {
//        [self.delegate didLogOut];
//    }

    if(![[self.chatDialog chatRoom].JID isEqualToString:roomJID]){
        return;
    }
    
    // save message
    [self.delegate didReciveMessages:@[message]];
}
-(void)sendMessage:(NSString *)msg toChatRoom:(QBChatRoom *)chatRoom save:(BOOL)save
{
   
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = msg;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @(save);
    [message setCustomParameters:params];
    [[ChatService instance] sendMessage:message toRoom:self.chatRoom];
    

}

-(void)leaveRoom:(BOOL)write
{
    if(self.chatDialog == nil)
        return;
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = [JsonMessageParser logOutMessageForUser:self.qbUser.login];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @(write);
    [message setCustomParameters:params];
    
    [[QBChat instance] sendChatMessage:message toRoom:self.chatRoom];

}
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result
{
    if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray *messages = res.messages;
        [self.delegate didReciveMessages:messages];
        
    }
}

#pragma mark 
#pragma mark -QBChatDelegate -

-(void)chatRoomDidEnter:(QBChatRoom *)room
{
    
    [self.delegate didConnectToRoom:room];
}

-(void)chatDidDeliverMessageWithID:(NSString *)messageID
{
    }

-(void)closeRoom{
    // Close the room
    if(self.chatDialog == nil) {
        return;
    }
    
    QBChatMessage* message = [[QBChatMessage alloc]init];
    message.text = [JsonMessageParser closeRoomMessage];
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
     [[QBChat instance] sendChatMessage:message toRoom:self.chatRoom];
}

@end
