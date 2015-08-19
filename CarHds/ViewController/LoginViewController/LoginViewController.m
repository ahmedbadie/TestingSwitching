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
#define LOGIN_BUTTON_PAD 144
@interface LoginViewController ()

@property (strong, nonatomic) IBOutlet UIView *forgetPasswordIphoneView;
@property (nonatomic) BOOL rememberMe;

@end


@implementation LoginViewController

-(void)saveUsername:(NSString *)username Password:(NSString *)password{
    
    NSUserDefaults *pref=[NSUserDefaults standardUserDefaults];
    [pref setObject:username forKey:@"username"];
    [pref setObject:password forKey:@"password"];
    [pref synchronize];
}

-(void)loadCredentials{
    NSString *username,*password;
    NSUserDefaults *prefs= [NSUserDefaults standardUserDefaults];
    if(self.rememberMe)
    {
        username=[prefs objectForKey:@"username"];
        password=[prefs objectForKey:@"password"];
    }
    //Noubi
    /*
    NSLog(@"User %@",username);
    NSLog(@"PAss %@",password);
    if([username length]==0)
    {
        username = nil;
    }
   */
    //Noubi
    
    if(username == nil || password == nil ||[username length] ==0 ){
        username = @"";
        password = @"";
    } else {
        self.view.hidden = YES;
        self.credentialsWasSaved = YES;
    }
    self.usernameTextField.text = username;
    self.passwordTextField.text = password;
}

- (IBAction)resetPasswordIPhone:(id)sender {
    NSString* text = [self.usernameTextField text];
    if(text==nil || text.length==0)
    {
        [self warnUserWithMessage:STRING(@"Missing username/email")];
        return;
    }
    [self forgetPasswordForText:text];
    
}

-(void) resetPasswordForEmail:(NSString*)email
{
    [QBRequest resetUserPasswordWithEmail:email successBlock:^(QBResponse *response) {
        [self.hud hide:YES];
        
        [self warnUserWithMessage:STRING(@"Password reset email was sent")];
    } errorBlock:^(QBResponse *response) {
        // Error
        [self.hud hide:YES];
        
        [self warnUserWithMessage:DESC(response.error.error)];
    }];
    
}
- (void)forgetPasswordForText:(NSString*) text {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = STRING(@"Reset Password");
    
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        
        
        if([self NSStringIsValidEmail:text])
        {
            [self resetPasswordForEmail:text];
        }else{
            [QBRequest usersWithLogins:@[text] successBlock:^(QBResponse *response, QBGeneralResponsePage *page, NSArray *users) {
                [self.hud hide:YES];
                
                if(users==nil || [users count]==0 )
                {
                    
                    [self warnUserWithMessage:[NSString stringWithFormat:STRING(@"No users with username"),[self.usernameTextField text]]];
                    return ;
                }
                QBUUser* user =[users firstObject];
                NSLog(@"User email %@",user.email);
                if(user.email !=nil && user.email.length !=0){
                    [self resetPasswordForEmail:user.email];
                    
                }else{
                    [self warnUserWithMessage:[NSString stringWithFormat:STRING(@"User doesn't have an email"),text]];
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
    if (self.credentialsWasSaved) {
        if(IS_IPAD)
            [self performSegueWithIdentifier:@"JoinMeetingHostIpad" sender:self];
        else
            [self performSegueWithIdentifier:@"JoinMeetingIphone" sender:self];
    }
}
-(void)viewWillAppear:(BOOL)animated {
    if (!self.credentialsWasSaved) {
        self.view.hidden = NO;
    }
    
    self.rememberMe = [Utilities loadRememberMe]; //return boolean value if remember me was checked before or not
    [self loadCredentials]; // get saved credentials username and password

}
- (void)viewDidLoad {
    [super viewDidLoad];
    //Remember me functions
    self.credentialsWasSaved = NO;
    if (IS_IPAD) {
        [self adjustView];
    }
    
    
    self.index = 0;
    self.state = NO;
    
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
}

-(void)adjustView {
    self.loginLabel.frame = CGRectMake(self.loginLabel.frame.origin.x, self.fieldsView.frame.origin.y - LOGIN_BUTTON_PAD, self.loginLabel.frame.size.width, self.loginLabel.frame.size.height);
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
        [self warnUserWithMessage:STRING(@"Time out")];
    }
}
-(void)validateCredentials {
    if([self.usernameTextField text]==nil || [self.usernameTextField text].length==0)
    {
        [self warnUserWithMessage:STRING(@"Missing Username")];
        return;
    }
    
    if([self.passwordTextField text]==nil || [self.passwordTextField text].length==0)
    {
        [self warnUserWithMessage:STRING(@"Missing password")];
        return;
    }else if ([self.passwordTextField text].length <8)
    {
        [self warnUserWithMessage:STRING(@"Password too short")];
        return;
    }

}

-(void)connectToQuickBlox {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText= STRING(@"Login");
    if([[QBChat instance]isLoggedIn])
    {
        [[QBChat instance] logout];
    }
    QBSessionParameters* parameters = [QBSessionParameters new];
    parameters.userLogin = [self.usernameTextField text];
    parameters.userPassword =[self.passwordTextField text];
    
    
    [QBRequest createSessionWithExtendedParameters:parameters successBlock:^(QBResponse *response, QBASession *session) {
        self.index++ ;
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
        NSLog(STRING(@"LoginSucceded"));
        
        //        NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
        //        NSLog(@"LoginSucceded [%@]",responseData);
        
        // If logged In continue to next step
        
        NSLog(@"loggedin with [%lu] [%@] [%lu]",(unsigned long)session.userID,session.token,(unsigned long)session.deviceID);
        
        
        [QBRequest logInWithUserLogin:[self.usernameTextField text] password:[self.passwordTextField text] successBlock:^(QBResponse *response, QBUUser *user) {
            // NSString *responseData = [[NSString alloc] initWithData:response.data encoding:NSUTF8StringEncoding];
            
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
                [self.hud hide:YES];
                if(IS_IPAD)
                    [self performSegueWithIdentifier:@"JoinMeetingHostIpad" sender:self];
                else
                    [self performSegueWithIdentifier:@"JoinMeetingIphone" sender:self];
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

- (IBAction)login:(id)sender {
    
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Login"];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"login_action"     // Event category (required)
                                                          action:@"button_press"  // Event action (required)
                                                           label:@"login"          // Event label
                                                           value:nil] build]];    // Event value
    
    [self validateCredentials];
    [Utilities saveRememberMe:YES];//Noubi

    [self saveUsername:self.usernameTextField.text Password:self.passwordTextField.text];

    
    [self connectToQuickBlox];
    
}


#pragma mark - UITextField Delegate -

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - QuickBlox Delegate -



#pragma mark - QBChat Delegate -

-(void) chatDidNotLogin
{
    [self.hud hide:YES];
    [self warnUserWithMessage:STRING(@"Failed to login")];
    self.state = NO;
}


#pragma mark - Prepare for Segue -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.hud.hidden = YES;
    if([segue.identifier isEqualToString:@"JoinMeetingIphone"]) {
        JoinRoomViewControllerClient *joinRoom = (JoinRoomViewControllerClient*)segue.destinationViewController;
        joinRoom.username = self.usernameTextField.text;
        joinRoom.state = self.state;
        joinRoom.user = self.user;
        joinRoom.credentialsWasSaved = self.credentialsWasSaved;
        self.credentialsWasSaved = NO;
    } else if ([segue.identifier isEqualToString:@"JoinMeetingHostIpad"]) {
        JoinRoomViewControllerHost *joinRoom = (JoinRoomViewControllerHost*)segue.destinationViewController;
        joinRoom.username = self.usernameTextField.text;
        joinRoom.state = self.state;
        joinRoom.user = self.user;
        joinRoom.credentialsWasSaved = self.credentialsWasSaved;
        self.credentialsWasSaved = NO;
    }
}

#pragma mark - Register -


- (IBAction)registerUser:(id)sender {
    [self performSegueWithIdentifier:@"RegisterNewUser" sender:self];
}

- (IBAction)forgetPassword:(id)sender {
    if(IS_IPAD)
        [self performSegueWithIdentifier:@"ForgetPassword" sender:self];
    else
        [self.view addSubview:self.forgetPasswordIphoneView];
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
