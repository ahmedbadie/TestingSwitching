//
//  LoginViewController.m
//  CaRHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "LoginViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
//        [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2];
    } errorBlock:^(QBResponse *response) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", "")
                                                        message:[response.error description]
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", "")
                                              otherButtonTitles:nil];
        [alert show];
    }];

    NSString* json = [JsonMessageParser loginMessageWithUsername:@"zonkoly"];
    NSLog(@"%@",json);
    NSData *theData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary* dict = [[CJSONDeserializer deserializer] deserialize:theData error:nil];
    NSLog(@"%@",[dict description]);
    // Do any additional setup after loading the view.
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

- (IBAction)startMeeting:(id)sender {
    /* 
     First Login with username and password, then 
        if Host 
            check if there is an existing room with the same name or not, if exist warn user, else create it
        else 
            check if there is an existing room with the same name, if exists join it
     */
//    [QuickBloxManager registerUserWithUsername:[self.usernameTextField text] andPassword:[self.passwordTextField text] withCompletionHandler:^(APIResponse *response) {
//
//        if(response.error)
//        {
//            NSLog(@"Failed with error %@",[response.error description]);
//        }else{
//            NSLog(@"Account created");
//        }
//    }];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText= @"Login";
    [QuickBloxManager loginWithUser:[self.usernameTextField text] andPassword:[self.passwordTextField text] withCompletionHandler:^(APIResponse *response) {
        if(response.error)
        {        [self.hud hide:YES];

            NSLog(@"Login Failed with error %@",[response.error description]);
            
        }else{
            NSLog(@"Login Succeded");
            // If logged In continue to next step
            if(!self.user || self.user.ID != ((QBUUser*)response.result).ID){
            self.user = (QBUUser*)response.result;
            self.user.password = [self.passwordTextField text];
            
            [QBChat instance].delegate =self;
                [[QBChat instance] loginWithUser:self.user];

            }else
            [self chatDidLogin];
        }
        
        
    }];
    
}

#pragma mark - Create Meeting Methods -

-(void) createMeetingRoom
{
    self.hud.labelText = @"Creating Meeting";
    
    // First check if chat dialouge exists or not?
    QBChatDialog* chatDialog = [QBChatDialog new];
    chatDialog.type = QBChatDialogTypePublicGroup;
    
    chatDialog.name = [self.meetingIDTextField text];
    [QBChat createDialog:chatDialog delegate:self];
}

#pragma mark - Join Meeting Methods -

-(void) joinMeetingRoom
{
    [self performSegueWithIdentifier:@"ClientViewSegue" sender:self];
    
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
        self.chatDialog = dialogRes.dialog;
        [self performSegueWithIdentifier:@"HostViewSegue" sender:self];
        
    }else if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        
        for(QBChatDialog* dialog in dialogs)
        {
            if([dialog.name isEqualToString:[self.meetingIDTextField text]])
            {
                switch ([self.operationTypeSegmentedControl selectedSegmentIndex]) {
                    case HOST_MEETING_INDEX:
                        [self warnUserWithMessage:@"Meeting ID already exists"];
                        break;
                    case JOIN_MEETING_INDEX:
                        self.chatDialog = dialog;
                        [self joinMeetingRoom];
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
                [self warnUserWithMessage:@"Meeting Id doesn't exists"];
                break;
            default:
                break;
        }

    }

}




#pragma mark - QBChat Delegate -

-(void)chatDidLogin
{
    // If successfully loged in to chat
    NSMutableDictionary* dictionary =[NSMutableDictionary dictionary];
    [dictionary setObject:[self.meetingIDTextField text] forKey:@"name"];
    [QBChat dialogsWithExtendedRequest:dictionary delegate:self];
//    switch ([self.operationTypeSegmentedControl selectedSegmentIndex]) {
//        case HOST_MEETING_INDEX:
//            [self createMeetingRoom];
//            break;
//        case JOIN_MEETING_INDEX:
//            [self joinMeetingRoom];
//            break;
//        default:
//            [self warnUserWithMessage:@"Operation Not defined"];
//            break;
//    }
    
}

-(void) chatDidNotLogin
{
    [self.hud hide:YES];
    [self warnUserWithMessage:@"Failed to login"];
}

-(void)chatRoomDidCreate:(NSString *)roomName
{
    NSLog(@"Chat room Created");
}

-(void)chatRoomDidEnter:(QBChatRoom *)room
{
    NSLog(@"Chat room joined");
}

-(void)chatRoomDidNotEnter:(NSString *)roomName error:(NSError *)error
{
    NSLog(@"Chat room wasn't entered due to error %@",[error description]);
}
- (void)chatRoomDidNotEnterRoomWithJID:(NSString *)roomJID error:(NSError *)error;
{
    NSLog(@"Chat room wasn't entered due to error %@",[error description]);

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

    if([segue.identifier isEqualToString:@"HostViewSegue"])
    {
        HostViewController* dst = segue.destinationViewController;
        dst.chatDialog = self.chatDialog;
        dst.user = self.user;
    }else if ([segue.identifier isEqualToString:@"ClientViewSegue"])
    {
        ClientViewController* dst = segue.destinationViewController;
        dst.chatDialog = self.chatDialog;
        dst.user = self.user;
    }
}
@end
