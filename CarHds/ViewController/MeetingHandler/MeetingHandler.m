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


-(void)connectToChatDialog:(QBChatDialog *)chatDialog
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatRoomDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessageFromRoom object:nil];
    
    [QBChat instance].delegate = self;
    // Join room
    QBChatRoom* room = [chatDialog chatRoom];
    self.chatRoom = room;
    if(self.chatDialog.type != QBChatDialogTypePrivate){
        [[ChatService instance] joinRoom:room completionBlock:^(QBChatRoom *joinedChatRoom) {
        }];
    }
    
    // get messages history
    [QBChat messagesWithDialogID:chatDialog.ID extendedRequest:nil delegate:self];

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
    
    if(![[self.chatDialog chatRoom].JID isEqualToString:roomJID]){
        return;
    }
    
    // save message
    [self.delegate didReciveMessages:@[message]];
}
-(void)sendMessage:(NSString *)msg toChatRoom:(QBChatRoom *)chatRoom
{
   
    
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = msg;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    [[ChatService instance] sendMessage:message toRoom:self.chatRoom];
    

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


@end
