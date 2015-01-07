//
//  LoginViewController.m
//  CaRHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//



#import "LoginViewController.h"
@interface LoginViewController ()
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL state;
@property (nonatomic) BOOL close;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@end


@implementation LoginViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
    self.state = NO;
    if(!IS_IPAD)
    {
        [self.operationTypeSegmentedControl setSelectedSegmentIndex:1];
        [self.operationTypeSegmentedControl setHidden:YES];
        [self.operationTypeSegmentedControl setEnabled:NO forSegmentAtIndex:0];
    }
    self.operationTypeSegmentedControl.layer.cornerRadius = 4.0f;
    self.operationTypeSegmentedControl.layer.masksToBounds = YES;
    self.goButton.layer.cornerRadius = self.goButton.frame.size.width/2;
    NSLog(@"----> %f    %f",self.goButton.frame.size.height/2,self.goButton.frame.size.width/2);
    self.goButton.clipsToBounds= YES;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void) stopTasks :(NSInteger) index
{
    if(self.index == index + 1 && self.state)
    {
        self.state = NO;

        [self.hud hide:YES];
        [self warnUserWithMessage:@"Time out"];
    }
}
- (IBAction)startMeeting:(id)sender {
    if([[QBChat instance]isLoggedIn])
    {
        [[QBChat instance] logout];
    }
    
    if(!IS_IPAD && [self.operationTypeSegmentedControl selectedSegmentIndex] == HOST_MEETING_INDEX)
    {
        [self warnUserWithMessage:@"Host Meeting is currently supported by IPad version only."];
        return;
    }

    if([self.meetingIDTextField text]==nil && [self.meetingIDTextField text].length==0)
    {
        [self warnUserWithMessage:@"Missing meeting name"];
        return;
    }
    if([self.usernameTextField text]==nil && [self.usernameTextField text].length==0)
    {
        [self warnUserWithMessage:@"Missing Username"];
        return;
    }
    
    if([self.passwordTextField text]==nil && [self.passwordTextField text].length==0)
    {
        [self warnUserWithMessage:@"Missing password"];
        return;
    }else if ([self.passwordTextField text].length <8)
    {
        [self warnUserWithMessage:@"Password too shor"];
        return;
    }
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText= STRING(@"Login");
    QBSessionParameters* parameters = [QBSessionParameters new];
    parameters.userLogin = [self.usernameTextField text];
    parameters.userPassword =[self.passwordTextField text];
   
//    [self performSelector:@selector(stopTasks:) withObject:@(self.index) afterDelay:3];
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        self.index++ ;
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSLog(STRING(@"LoginSucceded"));
        // If logged In continue to next step
        
            self.user =[QBUUser new];
            self.user.ID = session.userID;
            self.user.login = [self.usernameTextField text];
            self.user.password = [self.passwordTextField text];
            [defaults setObject:@(self.user.ID) forKey: USER_ID_KEY];
            [defaults setObject:self.user.password forKey:USER_PASSWORD_KEY];
            [QBChat instance].delegate =self;
            [[ChatService instance] loginWithUser:self.user completionBlock:^{
                [MeetingHandler sharedInstance].qbUser = [QBUUser new];
                [MeetingHandler sharedInstance].qbUser.login = [self.usernameTextField text];
                [MeetingHandler sharedInstance].qbUser.ID = self.user.ID;
                [MeetingHandler sharedInstance].qbUser.password= [self.passwordTextField text];
                [self chatDidLogin];
            }];
            
        
    } errorBlock:^(QBResponse *response) {
        
        NSLog(@"error login");
        
        NSDictionary* reasons =  response.error.reasons;
        NSLog(@"%@",[reasons description]);
        NSLog(@"error login message [%@]",QBDESC(response.error));
        self.state = NO;

        [self.hud hide:YES];
        [self warnUserWithMessage:QBDESC(response.error)];
    }];
    
}

#pragma mark - Create Meeting Methods -

-(void) createMeetingRoom
{
    self.hud.labelText = STRING(@"CreatingMeeting");
    
    // First check if chat dialouge exists or not?
    QBChatDialog* chatDialog = [QBChatDialog new];
    chatDialog.type = QBChatDialogTypePublicGroup;
    self.chatDialog = chatDialog;
    chatDialog.name = [self.meetingIDTextField text];
    
    [QBChat createDialog:chatDialog delegate:self];
    
    }

#pragma mark - Join Meeting Methods -

-(void) joinMeetingRoom
{
    self.state = NO;
    [self performSegueWithIdentifier:CLIENT_VIEW_SEGUE sender:self];
    
}

-(void) joinMeetingRoomAsHost
{
    self.state = NO;
    [self performSegueWithIdentifier:HOST_VIEW_SEGUE sender:self];
}
#pragma mark - UITextField Delegate - 

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - QuickBlox Delegate - 
-(void)completedWithResult:(Result *)result
{
    [self.hud hide:YES];
    if(result.success && [result isKindOfClass:[QBChatDialogResult class]])
    {
        
        QBChatDialogResult * dialogRes = (QBChatDialogResult*) result;
        QBChatDialog* dialog = dialogRes.dialog;
        self.chatDialog = dialog;
        [MeetingHandler sharedInstance].chatDialog = dialog;
        QBChatRoom* room = dialog.chatRoom;
        
        [MeetingHandler sharedInstance].chatRoom = room;
        [self performSegueWithIdentifier:@"HostViewSegue" sender:self];
        
    }else if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        QBChatDialog* chatDialog;
        QBChatRoom* room ;
        for(QBChatDialog* dialog in dialogs)
        {
            if([dialog.name isEqualToString:[self.meetingIDTextField text]])
            {
                
                NSDate* date = dialog.lastMessageDate;
                
                switch ([self.operationTypeSegmentedControl selectedSegmentIndex]) {
                    case HOST_MEETING_INDEX:
                        
                        if([Utilities withinRoomLife:date]){
                            [self warnUserWithMessage:@"Meeting room already exists"];
                        }else{
//                            [QBChat deleteDialogWithID:dialog.ID delegate:self];
                            chatDialog = dialog;
                            self.chatDialog = chatDialog;
                            [MeetingHandler sharedInstance].chatDialog = chatDialog;
                            room = chatDialog.chatRoom;
                            [MeetingHandler sharedInstance].chatRoom = room;

                            [self joinMeetingRoomAsHost];
                        }
                        break;
                    case JOIN_MEETING_INDEX:
                        if([Utilities withinRoomLife:date]){
                        chatDialog = dialog;
                        self.chatDialog = chatDialog;
                        [MeetingHandler sharedInstance].chatDialog = chatDialog;
                        room = chatDialog.chatRoom;
                        [MeetingHandler sharedInstance].chatRoom = room;
                        [self joinMeetingRoom];
                        }else{
                            [self warnUserWithMessage:STRING(@"RoomExpired")];
                        }
                        break;
                    default:
                        break;
                }
                return;
            }
        }
        // NOT Found
        
        switch ([self.operationTypeSegmentedControl selectedSegmentIndex]) {
            case HOST_MEETING_INDEX:
                [self createMeetingRoom];
                break;
            case JOIN_MEETING_INDEX:
                [self warnUserWithMessage:@"Meeting room doesn't exist"];
                break;
            default:
                break;
        }

        
    }else if ([result.answer isKindOfClass:[QBRestResponse class]])
    {
        if(result.success)
        {
            [self createMeetingRoom];
            
        }else{
            [self warnUserWithMessage:@"Meeting room already exists"];
        }
    
    }else{
        
        
        NSArray* errors = result.errors;
        for(NSString* error in errors)
            [self warnUserWithMessage:error];
    }

}




#pragma mark - QBChat Delegate -

-(void)chatDidLogin
{
    // If successfully loged in to chat
    NSMutableDictionary* dictionary =[NSMutableDictionary dictionary];
    [dictionary setObject:[self.meetingIDTextField text] forKey:@"name"];
    [QBChat dialogsWithExtendedRequest:dictionary delegate:self];
    
}

-(void) chatDidNotLogin
{
    [self.hud hide:YES];
    [self warnUserWithMessage:@"Failed to login"];
    self.state = NO;
}

-(void)chatRoomDidCreate:(NSString *)roomName
{
                QBChatDialog* chatDialog = self.chatDialog;
                [MeetingHandler sharedInstance].chatDialog = chatDialog;
            [self performSegueWithIdentifier:HOST_VIEW_SEGUE sender:self];
}

-(void)chatRoomDidEnter:(QBChatRoom *)room
{
    NSLog(@"Chat room joined");
}

-(void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error
{
    NSLog(@"Chat room wasn't entered due to error %@",DESC(error));
}
- (void)chatRoomDidNotEnterRoomWithJID:(NSString *)roomJID error:(NSError *)error;
{
    NSLog(@"Chat room wasn't entered due to error %@",DESC(error));

}
- (void)chatRoomDidLeave:(NSString *)roomName
{
    NSLog(@"Chat Room Did Leave");
}
/**
 Fired when you did leave room
 
 @param roomJID JID of room which you have leaved
 */
- (void)chatRoomDidLeaveRoomWithJID:(NSString *)roomJID
{
    NSLog(@"Chat Room Did leave room with JID");
}

/**
 Fired when you did destroy room
 
 @param roomName of room which you have destroyed
 */
- (void)chatRoomDidDestroy:(NSString *)roomName
{
    NSLog(@"Chat Room Did Destroy");
}

#pragma mark - Prepare for Segue - 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if([segue.identifier isEqualToString:HOST_VIEW_SEGUE])
    {
        HostViewController* dst = segue.destinationViewController;
        dst.chatDialog = self.chatDialog;
        dst.user = self.user;
    }else if ([segue.identifier isEqualToString:CLIENT_VIEW_SEGUE])
    {
        ClientViewController* dst = segue.destinationViewController;
        dst.chatDialog = self.chatDialog;
        dst.user = self.user;
    }else if ([segue.identifier isEqualToString:@"RegisterNewUserIPad"] || [segue.identifier isEqualToString:@"RegisterNewUserIPhone"])
    {
        RegisterViewController* dst = (RegisterViewController*)segue.destinationViewController;
        dst.delegate = self;
    }
}


#pragma mark - Register - 


- (IBAction)registerUser:(id)sender {

    if(IS_IPAD)
    {
        [self performSegueWithIdentifier:@"RegisterNewUserIPad" sender:self];
    }else{
        [self performSegueWithIdentifier:@"RegisterNewUserIPhone" sender:self];
    }
    
    
}

@end
