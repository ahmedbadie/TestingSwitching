//
//  LoginViewController.m
//  CaRHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//



#import "LoginViewController.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface LoginViewController ()
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL state;
@property (nonatomic) BOOL close;
@property (strong, nonatomic) IBOutlet UIView *forgetPasswordIphoneView;
@property (weak, nonatomic) IBOutlet UIButton *goButton;
@property (weak, nonatomic) IBOutlet UITextView *forgetPasswordText;
@property (weak, nonatomic) IBOutlet UIButton *rememberMeButton;
@property (nonatomic) BOOL rememberMe;

@end


@implementation LoginViewController

-(void)saveRememberMe:(BOOL)rememberMe{
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:[NSNumber numberWithBool:rememberMe] forKey:@"rememberMe"];
    [pref synchronize];
}

-(BOOL)loadRememberMe{
    NSNumber * rememberMe;
    NSUserDefaults *prefs=[NSUserDefaults standardUserDefaults];
    rememberMe=[prefs objectForKey:@"rememberMe"];
    
    if(rememberMe != nil){
        return  rememberMe.boolValue;
    }
    
    return  false;
}

-(void)saveUsername:(NSString *)username Password:(NSString *)password{
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:username forKey:@"username"];
    [pref setObject:password forKey:@"password"];
    [pref synchronize];
}

-(void)loadCredentials{
    NSString *username,*password;
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    username=[prefs objectForKey:@"username"];
    password=[prefs objectForKey:@"password"];
    
    if(username == nil || password == nil){
        username = @"";
        password = @"";
    }
    
    self.usernameTextField.text = username;
    self.passwordTextField.text = password;
}

- (IBAction)resetPasswordIPhone:(id)sender {
    NSString* text = [self.usernameTextField text];
    if(text==nil || text.length==0)
    {
        [self warnUserWithMessage:@"Missing username/email"];
        return;
    }
    [self forgetPasswordForText:text];
    
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) resetPasswordForEmail:(NSString*)email
{
    [QBRequest resetUserPasswordWithEmail:email successBlock:^(QBResponse *response) {
        [self.hud hide:YES];
        
        [self warnUserWithMessage:@"Password reset email was sent"];
    } errorBlock:^(QBResponse *response) {
        // Error
        [self.hud hide:YES];
        
        [self warnUserWithMessage:DESC(response.error.error)];
    }];
    
}
- (void)forgetPasswordForText:(NSString*) text {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Reset Password";
    
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        
        
        if([self NSStringIsValidEmail:text])
        {
            [self resetPasswordForEmail:text];
        }else{
            [QBRequest usersWithLogins:@[text] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                [self.hud hide:YES];
                
                if(users==nil || [users count]==0 )
                {
                    
                    [self warnUserWithMessage:[NSString stringWithFormat:@"No users with username %@",[self.usernameTextField text]]];
                    return ;
                }
                QBUUser* user =[users firstObject];
                NSLog(@"User email %@",user.email);
                if(user.email !=nil && user.email.length !=0){
                    [self resetPasswordForEmail:user.email];
                    
                }else{
                    [self warnUserWithMessage:[NSString stringWithFormat:@"User %@ doesn't have an email",text]];
                }
                
            } errorBlock:^(QBResponse *response) {
                
                [self.hud hide:YES];
                [self warnUserWithMessage:DESC(response.error.error)];
            }];
            
        }
    } errorBlock:^(QBResponse *response) {
        [self.hud hide:YES];
        
        [self warnUserWithMessage:DESC(response.error.error)];
        
    }];
}


- (IBAction)closeForgetPasswordIphone:(id)sender {
    [self.forgetPasswordIphoneView removeFromSuperview];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    if(IS_IPAD){
    //        // Host
    //        [self.usernameTextField setText:@"host"];
    //    }else{
    //        // Client
    //        [self.usernameTextField setText:@"client"];
    //    }
    //    [self.passwordTextField setText:@"12345678"];
    //    [self.meetingIDTextField setText:@"Inova Room"];
    
}

-(void)updateRemberMeButton:(BOOL)rememberMe{
    if(rememberMe){
        [self.rememberMeButton setImage:[UIImage imageNamed:@"checkbox_checked"] forState:UIControlStateNormal];
    }else{
        [self.rememberMeButton setImage:[UIImage imageNamed:@"checkbox_new"] forState:UIControlStateNormal];
    }
}

-(IBAction)rememberMeClicked:(id)sender{
    
    self.rememberMe = !self.rememberMe;
    [self saveRememberMe:self.rememberMe];
    [self updateRemberMeButton:self.rememberMe];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rememberMe = [self loadRememberMe];
    [self updateRemberMeButton:self.rememberMe];
    
    [self loadCredentials];
    
    
    self.index = 0;
    self.state = NO;
    if(!IS_IPAD)
    {
        [self.operationTypeSegmentedControl setSelectedSegmentIndex:1];
        [self.operationTypeSegmentedControl setHidden:YES];
        [self.operationTypeSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        self.titleLabel.text = @"Join Meeting";
    }else{
        self.titleLabel.text = @"Open or Join Meeting";
    }
    
    self.operationTypeSegmentedControl.layer.cornerRadius = 4.0f;
    self.operationTypeSegmentedControl.layer.masksToBounds = YES;
    self.goButton.clipsToBounds= YES;
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        [self setPortaitMode];
    }else if (UIInterfaceOrientationIsLandscape(orientation)){
        [self setLandscapeMode];
    }else{
        [self setPortaitMode];
    }
    
    
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
    NSLog(@"startMeeting");
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"login_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"login"          // Event label
                                                           value:nil] build]];    // Event value
    
    
    if([[QBChat instance]isLoggedIn])
    {
        [[QBChat instance] logout];
    }
    
    if(!IS_IPAD && [self.operationTypeSegmentedControl selectedSegmentIndex] == HOST_MEETING_INDEX)
    {
        [self warnUserWithMessage:@"Host Meeting is currently supported by IPad version only."];
        return;
    }
    
    if([self.meetingIDTextField text]==nil || [self.meetingIDTextField text].length==0)
    {
        [self warnUserWithMessage:@"Missing meeting name"];
        return;
    }
    if([self.usernameTextField text]==nil || [self.usernameTextField text].length==0)
    {
        [self warnUserWithMessage:@"Missing Username"];
        return;
    }
    
    if([self.passwordTextField text]==nil || [self.passwordTextField text].length==0)
    {
        [self warnUserWithMessage:@"Missing password"];
        return;
    }else if ([self.passwordTextField text].length <8)
    {
        [self warnUserWithMessage:@"Password too short"];
        return;
    }
    
    if(self.rememberMe){
        [self saveUsername:self.usernameTextField.text Password:self.passwordTextField.text];
    }else{
        [self saveUsername:@"" Password:@""];
    }
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText= STRING(@"Login");
    QBSessionParameters* parameters = [QBSessionParameters new];
    parameters.userLogin = [self.usernameTextField text];
    parameters.userPassword =[self.passwordTextField text];
    
    
    //
    //
    //    [QBRequest logInWithUserLogin:[self.usernameTextField text] password:[self.passwordTextField text] successBlock:^(QBResponse *response, QBUUser *user) {
    //        NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
    //
    //        NSLog(@"logInWithUserLogin ******* success");
    //    } errorBlock:^(QBResponse *response) {
    //
    //        NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
    //
    //        NSLog(@"logInWithUserLogin ******* fail");
    //
    //    }];
    //
    //    return;
    
    //    [self performSelector:@selector(stopTasks:) withObject:@(self.index) afterDelay:3];
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        self.index++ ;
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSLog(STRING(@"LoginSucceded"));
        
        //        NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
        //        NSLog(@"LoginSucceded [%@]",responseData);
        
        // If logged In continue to next step
        
        NSLog(@"loggedin with [%lu] [%@] [%lu]",(unsigned long)session.userID,session.token,(unsigned long)session.deviceID);
        
        
        [QBRequest logInWithUserLogin:[self.usernameTextField text] password:[self.passwordTextField text] successBlock:^(QBResponse *response, QBUUser *user) {
            NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
            
            NSLog(@"logInWithUserLogin ******* success");
            
            
            //            self.user =[QBUUser new];
            //            self.user.ID = session.userID;
            //            self.user.login = [self.usernameTextField text];
            //            self.user.password = [self.passwordTextField text];
            
            self.user = user;
            self.user.password = [self.passwordTextField text];
            [defaults setObject:@(self.user.ID) forKey: USER_ID_KEY];
            [defaults setObject:self.user.password forKey:USER_PASSWORD_KEY];
            
            [[ChatService shared] loginWithUser:self.user completionBlock:^{
                NSLog(@"loginWithUser completionBlock");
                [MeetingHandler sharedInstance].qbUser = [QBUUser new];
                [MeetingHandler sharedInstance].qbUser.login = [self.usernameTextField text];
                [MeetingHandler sharedInstance].qbUser.ID = self.user.ID;
                [MeetingHandler sharedInstance].qbUser.password= [self.passwordTextField text];
                [self chatDidLogin];
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

#pragma mark - Create Meeting Methods -

-(void) createMeetingRoom
{
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
                
                switch ([self.operationTypeSegmentedControl selectedSegmentIndex]) {
                    case HOST_MEETING_INDEX:
                    {
                        // first check for last message text
                        BOOL canResume = NO;
                        if(dialog.userID == self.user.ID){
                            canResume = YES;
                        }
                        if( !canResume && [Utilities withinRoomLife:date] && ![JsonMessageParser isCloseRoomMessage:dialog.lastMessageText] ){
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
                    }
                        break;
                    case JOIN_MEETING_INDEX:
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
        
        NSLog(@"completedWithResult QBRestResponse");
        
        if(result.success)
        {
            [self createMeetingRoom];
            
        }else{
            [self warnUserWithMessage:@"Meeting room already exists"];
        }
        
    }else{
        
        NSLog(@"completedWithResult errors");
        
        NSArray* errors = result.errors;
        for(NSString* error in errors)
            [self warnUserWithMessage:error];
    }
    
}




#pragma mark - QBChat Delegate -

-(void)chatDidLogin
{
    NSLog(@"chatDidLogin [%@]",[self.meetingIDTextField text]);
    // If successfully loged in to chat
    NSMutableDictionary* dictionary =[NSMutableDictionary dictionary];
    [dictionary setObject:[self.meetingIDTextField text] forKey:@"ـname"];
    //    [QBChat dialogsWithExtendedRequest:dictionary delegate:self];
    
    
    [QBRequest dialogsForPage:nil extendedRequest:dictionary successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        
        [self.hud hide:YES];
        NSLog(@"completedWithResult success QBDialogsPagedResult");
        
        //
        NSArray *dialogs = dialogObjects;
        QBChatDialog* chatDialog;
        QBChatRoom* room ;
        
        for(QBChatDialog* dialog in dialogs)
        {
            //            NSLog(@"[%@]  [%lu]  [%@]  [%@]",dialog.roomJID,(unsigned long)dialog.userID,dialog.ID,dialog.name);
            
            if([dialog.name isEqualToString:[self.meetingIDTextField text]])
            {
                
                NSDate* date = dialog.lastMessageDate;
                
                switch ([self.operationTypeSegmentedControl selectedSegmentIndex]) {
                    case HOST_MEETING_INDEX:
                    {
                        // first check for last message text
                        BOOL canResume = NO;
                        if(dialog.userID == self.user.ID){
                            canResume = YES;
                        }
                        if( !canResume && [Utilities withinRoomLife:date] && ![JsonMessageParser isCloseRoomMessage:dialog.lastMessageText] ){
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
                    }
                        break;
                    case JOIN_MEETING_INDEX:
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
        
        
        
        
        
    } errorBlock:^(QBResponse *response) {
        [self.hud hide:YES];
    }];
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
- (void)chatRoomDidLeave:(NSString *)roomName
{
    NSLog(@"Chat Room Did Leave [%@]",roomName);
}
/**
 Fired when you did leave room
 
 @param roomJID JID of room which you have leaved
 */
- (void)chatRoomDidLeaveRoomWithJID:(NSString *)roomJID
{
    NSLog(@"Chat Room Did leave room with JID [%@]",roomJID);
}

/**
 Fired when you did destroy room
 
 @param roomName of room which you have destroyed
 */
- (void)chatRoomDidDestroy:(NSString *)roomName
{
    NSLog(@"Chat Room Did Destroy [%@]",roomName);
}

#pragma mark - Prepare for Segue -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:HOST_VIEW_SEGUE])
    {
        HostViewController* dst = segue.destinationViewController;
        dst.chatDialog = self.chatDialog;
        dst.user = self.user;
        dst.delegate = self;
    }else if ([segue.identifier isEqualToString:CLIENT_VIEW_SEGUE])
    {
        ClientViewController* dst = segue.destinationViewController;
        dst.chatDialog = self.chatDialog;
        dst.user = self.user;
    }else if ([segue.identifier isEqualToString:@"RegisterNewUserIPad"] || [segue.identifier isEqualToString:@"RegisterNewUserIPhone"])
    {
        RegisterViewController* dst = (RegisterViewController*)segue.destinationViewController;
        dst.delegate = self;
    }else  if([segue.identifier isEqualToString:HOST_CONCLUDE_SEGUE])
    {
        HostConcludeViewController* dst = segue.destinationViewController;
        dst.delegate = self;
        dst.users = self.users;
        [MeetingHandler sharedInstance].delegate = dst;
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

- (IBAction)forgetPassword:(id)sender {
    if(IS_IPAD)
        [self performSegueWithIdentifier:[NSString stringWithFormat:@"ForgetPassword%@",IS_IPAD? @"IPad":@"IPhone" ]sender:self];
    else
        [self.view addSubview:self.forgetPasswordIphoneView];
}

-(void)concludeMeeting:(NSArray *)data
{
    self.users = [data firstObject];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:HOST_CONCLUDE_SEGUE sender:self];
    }];
}

-(void) setLandscapeMode{}

-(void) setPortaitMode{}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    switch (toInterfaceOrientation) {
        case UIDeviceOrientationPortrait:
            [self setPortaitMode];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self setLandscapeMode];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self setLandscapeMode];
            break;
        default:
            break;
    }
}

-(NSUInteger)supportedInterfaceOrientations
{
    return IS_IPAD? UIInterfaceOrientationMaskAll: UIInterfaceOrientationPortrait;
}


-(BOOL)shouldAutorotate
{
    return IS_IPAD;
}


@end
