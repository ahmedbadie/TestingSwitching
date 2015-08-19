//
//  JoinRoomViewControllerClient.m
//  CarHds
//
//  Created by Inova PC 09 on 6/22/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "JoinRoomViewControllerClient.h"

@implementation JoinRoomViewControllerClient
-(void)viewDidLoad {
    [super viewDidLoad];
    if (self.credentialsWasSaved) {
        
        [self connectToQuickBlox];
    }
    NSString *logoutButtonText = [NSString stringWithFormat:STRING(@", do you want to Logout?"), self.username];
    [self.logoutButton setTitle:logoutButtonText forState: UIControlStateNormal];
}
-(void)connectToQuickBlox {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText= STRING(@"Login");
    NSString *username,*password;
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    username=[prefs objectForKey:@"username"];
    password=[prefs objectForKey:@"password"];
    
    
    if([[QBChat instance]isLoggedIn])
    {
        [[QBChat instance] logout];
    }
    QBSessionParameters* parameters = [QBSessionParameters new];
    parameters.userLogin = username;
    parameters.userPassword =password;
    
    
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSLog(STRING(@"LoginSucceded"));
        
        //        NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
        //        NSLog(@"LoginSucceded [%@]",responseData);
        
        // If logged In continue to next step
        
        NSLog(@"loggedin with [%lu] [%@] [%lu]",(unsigned long)session.userID,session.token,(unsigned long)session.deviceID);
        
        
        [QBRequest logInWithUserLogin:username password:password successBlock:^(QBResponse *response, QBUUser *user) {
            // NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
            
            NSLog(@"logInWithUserLogin ******* success");
            
            
            //            self.user =[QBUUser new];
            //            self.user.ID = session.userID;
            //            self.user.login = [self.usernameTextField text];
            //            self.user.password = [self.passwordTextField text];
            
            self.user = user;
            self.user.password = password;
            [defaults setObject:@(self.user.ID) forKey: USER_ID_KEY];
            [defaults setObject:self.user.password forKey:USER_PASSWORD_KEY];
            
            [[ChatService shared] loginWithUser:self.user completionBlock:^{
                NSLog(@"loginWithUser completionBlock");
                [MeetingHandler sharedInstance].qbUser = [QBUUser new];
                [MeetingHandler sharedInstance].qbUser.login = username;
                [MeetingHandler sharedInstance].qbUser.ID = self.user.ID;
                [MeetingHandler sharedInstance].qbUser.password= password;
                [self.hud hide:YES];
                
            }];
            
        } errorBlock:^(QBResponse *response) {
            
            NSLog(@"logInWithUserLogin error");
            
            NSDictionary* reasons =  response.error.reasons;
            NSLog(@"logInWithUserLogin error %@",[reasons description]);
            
            self.state = NO;
            
            [self.hud hide:YES];
            [self warnUserWithMessage:DESC(response.error.error)];
        }];
        
    } errorBlock:^(QBResponse *response) {
        
        NSLog(@"error login");
        
        NSDictionary* reasons =  response.error.reasons;
        NSLog(@"error login %@",[reasons description]);
        //        NSLog(@"error login message [%@]",QBDESC(response.error));
        self.state = NO;
        
        [self.hud hide:YES];
        [self warnUserWithMessage:DESC(response.error.error)];
    }];
}


-(void) createMeetingRoom {
    self.hud.labelText = STRING(@"CreatingMeeting");
    
    // First check if chat dialouge exists or not?
    QBChatDialog* chatDialog = [QBChatDialog new];
    chatDialog.type = QBChatDialogTypePublicGroup;
    chatDialog.name = [self.meetingIDTextField text];
    self.chatDialog = chatDialog;
    
    //    [QBChat createDialog:chatDialog delegate:self];
    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        
        NSLog(@"createDialog:chatDialog successBlock [%@][%@]",createdDialog.ID,createdDialog.name);
        QBChatDialog* dialog = createdDialog;
        self.chatDialog = dialog;
        [MeetingHandler sharedInstance].chatDialog = dialog;
        QBChatRoom* room = dialog.chatRoom;
        
        [MeetingHandler sharedInstance].chatRoom = room;
        [self performSegueWithIdentifier:@"HostViewSegue" sender:self];
        
    } errorBlock:^(QBResponse *response) {
        
    }];
    
}
 #pragma mark - Join Meeting Methods -
 
-(void) joinMeetingRoom {
    self.state = NO;
    [self performSegueWithIdentifier:CLIENT_VIEW_SEGUE sender:self];
    
}


#pragma mark - UITextField Delegate -

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

 #pragma mark - QuickBlox Delegate -

-(void)completedWithResult:(QBResult *)result
{
    NSLog(@"Loginviewcontroller completedWithResult");
    [self.hud hide:YES];
    if(result.success && [result isKindOfClass:[QBChatDialogResult class]])
    {
        NSLog(@"completedWithResult success QBChatDialogResult");
        
        QBChatDialogResult * dialogRes = (QBChatDialogResult*) result;
        QBChatDialog* dialog = dialogRes.dialog;
        self.chatDialog = dialog;
        [MeetingHandler sharedInstance].chatDialog = dialog;
        QBChatRoom* room = dialog.chatRoom;
        
        [MeetingHandler sharedInstance].chatRoom = room;
        [self performSegueWithIdentifier:@"HostViewSegue" sender:self];
        
    }else if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        NSLog(@"completedWithResult success QBDialogsPagedResult");
        
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        QBChatDialog* chatDialog;
        QBChatRoom* room ;
        
        for(QBChatDialog* dialog in dialogs)
        {
            NSLog(@"[%@]  [%lu]  [%@]  [%@]",dialog.roomJID,(unsigned long)dialog.userID,dialog.ID,dialog.name);
            
            if([dialog.name isEqualToString:[self.meetingIDTextField text]])
            {
                
                NSDate* date = dialog.lastMessageDate;
                if([Utilities withinRoomLife:date] && ![JsonMessageParser isCloseRoomMessage:dialog.lastMessageText]){
                    // first check for last message text
                    chatDialog = dialog;
                    self.chatDialog = chatDialog;
                    [MeetingHandler sharedInstance].chatDialog = chatDialog;
                    room = chatDialog.chatRoom;
                    [MeetingHandler sharedInstance].chatRoom = room;
                    [self joinMeetingRoom];
                }else{
                    [self warnUserWithMessage:STRING(@"RoomExpired")];
                }
                
                return;
            }
        }
        // NOT Found
        [self warnUserWithMessage:STRING(@"Meeting room doesn't exist")];
        
        
        
    }else if ([result.answer isKindOfClass:[QBRestResponse class]])
    {
        
        NSLog(@"completedWithResult QBRestResponse");
        
        if(result.success)
        {
            [self createMeetingRoom];
            
        }else{
            [self warnUserWithMessage:STRING(@"Meeting room already exists")];
        }
        
    }else{
        
        NSLog(@"completedWithResult errors");
        
        NSArray* errors = result.errors;
        for(NSString* error in errors)
            [self warnUserWithMessage:error];
    }
    
}

 
- (IBAction)enterMeeting:(id)sender {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText= STRING(@"Loading");
    [self chatDidLogin];
}
 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.hud.hidden = YES;
    if ([segue.identifier isEqualToString:CLIENT_VIEW_SEGUE]) {
        ClientViewController* dst = segue.destinationViewController;
        dst.chatDialog = self.chatDialog;
        dst.user = self.user;
    }
}
- (IBAction)logout:(UIButton *)sender {
    if(self.user!=nil)
    {
        NSString* msg = [JsonMessageParser logOutMessageForUser:self.user.login];
        QBChatRoom* chatRoom = [self.chatDialog chatRoom];
        
        [MeetingHandler sharedInstance].logOut = YES;
        [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:chatRoom save:YES];
    }
    [Utilities saveRememberMe:NO];
    [self didLogOut];
        

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

 #pragma mark - QBChat Delegate -
-(void)chatDidLogin
{
    NSLog(@"chatDidLogin [%@]",[self.meetingIDTextField text]);
    // If successfully loged in to chat
    NSMutableDictionary* dictionary =[NSMutableDictionary dictionary];
    // This constraint is to make sure you get only one record for the dialog with the correct name
    [dictionary setObject:[self.meetingIDTextField text] forKey:@"name"];
    //    [QBChat dialogsWithExtendedRequest:dictionary delegate:self];
    
    
    [QBRequest dialogsForPage:nil extendedRequest:dictionary successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        
        [self.hud hide:YES];
        NSLog(@"completedWithResult success QBDialogsPagedResult [%d]",dialogObjects.count);
        
        //
        NSArray *dialogs = dialogObjects;
        QBChatDialog* chatDialog;
        QBChatRoom* room ;
        
        NSString* message;
        NSString* senderID;
        NSString* meetingID;
        NSDictionary* params;
        for(QBChatDialog* dialog in dialogs)
        {
            //            NSLog(@"[%@]  [%lu]  [%@]  [%@]",dialog.roomJID,(unsigned long)dialog.userID,dialog.ID,dialog.name);
            
            if([dialog.name isEqualToString:[self.meetingIDTextField text]])
            {
                
                NSDate* date = dialog.lastMessageDate;
                if([Utilities withinRoomLife:date] && ![JsonMessageParser isCloseRoomMessage:dialog.lastMessageText]){
                    // first check for last message text
                    chatDialog = dialog;
                    self.chatDialog = chatDialog;
                    [MeetingHandler sharedInstance].chatDialog = chatDialog;
                    room = chatDialog.chatRoom;
                    [MeetingHandler sharedInstance].chatRoom = room;
                    
                    message = @"enter_meeting";
                    senderID = self.username;
                    meetingID = [MeetingHandler sharedInstance].chatDialog.name;
                    params = [NSDictionary dictionaryWithObjectsAndKeys:senderID,@"SenderID",
                              @"dbh.RH.CaRHds.SVC1",@"AppGuid",
                              message,@"Message",
                              meetingID,@"MeetingID",
                              @"8E1ED66A-ECB5-422D-B8B8-77FF9E195D7F",@"AppCred", nil];
                    [self sendSignalToCarhdsServerWithParams:params];
                    
                    [self joinMeetingRoom];
                }else{
                    
                    message = @"login_fail_RoomExpired";
                    senderID = self.username;
                    params = [NSDictionary dictionaryWithObjectsAndKeys:senderID,@"SenderID",
                              @"dbh.RH.CaRHds.SVC1",@"AppGuid",
                              message,@"Message",
                              @"8E1ED66A-ECB5-422D-B8B8-77FF9E195D7F",@"AppCred", nil];
                    [self sendSignalToCarhdsServerWithParams:params];
                    
                    [self warnUserWithMessage:STRING(@"RoomExpired")];
                }
                
                return;
            }
        }
        // NOT Found
        message = @"login_fail_Room_Doesn't_exist";
        senderID = self.username;
        params = [NSDictionary dictionaryWithObjectsAndKeys:senderID,@"SenderID",
                  @"dbh.RH.CaRHds.SVC1",@"AppGuid",
                  message,@"Message",
                  @"8E1ED66A-ECB5-422D-B8B8-77FF9E195D7F",@"AppCred", nil];
        [self sendSignalToCarhdsServerWithParams:params];
        
        [self warnUserWithMessage:STRING(@"Meeting room doesn't exist")];
    
    } errorBlock:^(QBResponse *response) {
        [self.hud hide:YES];
    }];
}

-(void) chatDidNotLogin
{
    [self.hud hide:YES];
    [self warnUserWithMessage:STRING(@"Failed to login")];
    self.state = NO;
}


-(void)chatRoomDidEnter:(QBChatRoom *)room
{
    NSLog(@"Chat room joined [%@]",room.name);
}

-(void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error
{
    NSLog(@"Chat room name [%@] wasn't entered due to error %@",roomName,DESC(error));
}
- (void)chatRoomDidNotEnterRoomWithJID:(NSString *)roomJID error:(NSError *)error;
{
    NSLog(@"Chat room jid [%@] wasn't entered due to error %@",roomJID,DESC(error));
    
}
/*- (void)chatRoomDidLeave:(NSString *)roomName
{
    NSLog(@"Chat Room Did Leave [%@]",roomName);
}
/**
 Fired when you did leave room
 
 @param roomJID JID of room which you have leaved
 */
/*- (void)chatRoomDidLeaveRoomWithJID:(NSString *)roomJID
{
    NSLog(@"Chat Room Did leave room with JID [%@]",roomJID);
}*/

/**
 Fired when you did destroy room
 
 @param roomName of room which you have destroyed
 */
/*- (void)chatRoomDidDestroy:(NSString *)roomName
{
    NSLog(@"Chat Room Did Destroy [%@]",roomName);
}*/


@end
