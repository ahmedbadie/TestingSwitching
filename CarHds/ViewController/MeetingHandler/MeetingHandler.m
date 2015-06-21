//
//  MeetingHandler.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "MeetingHandler.h"

@interface MeetingHandler () <QBChatDelegate>

@end

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
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
    //                                                 name:kNotificationDidReceiveNewMessage object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
    //                                                 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
    
    // Join room
    QBChatRoom* room = self.chatDialog.chatRoom;
    self.chatRoom = room;
    [[QBChat instance] addDelegate:[ChatService shared]];
    if(self.chatDialog.type != QBChatDialogTypePrivate){
        [[ChatService shared] joinRoom:self.chatRoom completionBlock:^(QBChatRoom * room) {
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
//    [QBChat messagesWithDialogID:self.chatDialog.ID extendedRequest:nil delegate:self];
    
    //    [QBRequest messagesWithDialogID:self.chatDialog.ID extendedRequest:nil forPage:nil successBlock:^(QBResponse *response, NSArray *array, QBResponsePage *page) {
    //
    //
    //        //        if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
    //        //            QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
    //        //            NSArray *messages = res.messages;
    //        //            [self.delegate didReciveMessages:messages];
    //        //
    //        //        }
    //
    //    } errorBlock:^(QBResponse *response) {
    //
    //    }];
    //
    
    //  Tmp fix for not returning all the messages in the dialgo
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:1000 skip:0];
    NSMutableDictionary *extendedRequest = [NSMutableDictionary new];
    
    // This constraint is to make sure you get only message records within the valid meeting time duration (6 hours) any message before such time will not be returned
    NSDate *now = [NSDate date];
    NSDate *since = [now dateByAddingTimeInterval:-MAX_TIME_INTERVAL];
    extendedRequest[@"date_sent[gte]"]= @([since timeIntervalSince1970]);
    
     [QBRequest messagesWithDialogID:self.chatDialog.ID extendedRequest:extendedRequest forPage:page successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *page) {
        
        [self.delegate didReciveMessages:messages];
        
    } errorBlock:^(QBResponse *response) {
        
    }];

    
    
}


#pragma mark - Chat Notification Methods -

//- (void)chatDidReceiveMessageNotification:(NSNotification *)notification{
//
//    QBChatMessage *message = notification.userInfo[kMessage];
//    if(message.senderID != self.chatDialog.recipientID){
//        return;
//    }
//
//    // save message
//    [self.delegate didReciveMessages:@[message]];
//}
//
//- (void)chatRoomDidReceiveMessageNotification:(NSNotification *)notification{
//    QBChatMessage *message = notification.userInfo[kMessage];
//    NSString *roomJID = notification.userInfo[kRoomJID];
//    if(![[self.chatDialog chatRoom].JID isEqualToString:roomJID]){
//        return;
//    }
//
//    // save message
//    [self.delegate didReciveMessages:@[message]];
//}



- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    
    if(message.senderID != self.chatDialog.recipientID){
        return;
    }
    
    // save message
    [self.delegate didReciveMessages:@[message]];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoom:(NSString *)roomJID{
    
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
    [[ChatService shared] sendMessage:message toRoom:self.chatRoom];
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

-(void)completedWithResult:(QBResult *)result{
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
