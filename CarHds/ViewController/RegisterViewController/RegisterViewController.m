//
//  RegisterViewController.m
//  CarHds
//
//  Created by Inova010 on 1/1/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "RegisterViewController.h"
#define IPAD_FOOTER_Y_PAD 49
@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIView *fieldView;

@end

@implementation RegisterViewController

#pragma mark - view modifications -
-(void)viewDidLoad {
    [super viewDidLoad];
    [self setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self adjustViewControllerBasedOnOrientation];

}

-(void)adjustViewControllerBasedOnOrientation {
    if (IS_IPAD) {
        self.footerView.frame = CGRectMake(self.footerView.frame.origin.x,(self.fieldView.frame.origin.y+self.fieldView.frame.size.height )+ IPAD_FOOTER_Y_PAD, self.footerView.frame.size.width, self.footerView.frame.size.height);
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
}


#pragma mark - keyboard delegates -
- (void)keyboardWasShown:(NSNotification *)notification {
    _registerScrollView.contentSize = CGSizeMake(320, 700);
    [_registerScrollView setContentOffset:CGPointMake(0, 100) animated:YES];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
        _registerScrollView.contentSize = _registerScrollView.frame.size;
}
- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self deregisterFromKeyboardNotifications];
    
    [super viewWillDisappear:animated];
    
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
- (IBAction)buttonClicked:(UIButton *)sender {
    
    
    switch (sender.tag) {
        case 0:
            [self registerUser];
            break;
        case 1:
            [self.delegate warnUserWithMessage:STRING(@"Creation Canceled")];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            break;
    }
}


-(void) registerUser
{
    NSString * username = [[self.usernameTextField text] lowercaseString];
    NSString * password =[self.passwordTextField text];
    NSString * email = [self.emailTextField text];
    
    NSString * firstName = [self.firstNameTextField text];
    NSString * lastName = [self.lastNameTextField text];

    if (username ==nil || username.length ==0)
    {
        [self warnUserWithMessage:STRING(@"Can't create a user with empty username")];
        return;
    }

    if(password==nil||password.length < 8 )
    {
        [self warnUserWithMessage:STRING(@"Password should be more than 8 letters")];
        return;
    }
    if(email==nil||email.length ==0 ||![self NSStringIsValidEmail:email])
    {
        [self warnUserWithMessage:STRING(@"Invalid email Address")];
        return;
    }
    
    if (firstName ==nil || firstName.length ==0)
    {
        [self warnUserWithMessage:STRING(@"Can't create a user with empty first name")];
        return;
    }
    
    
    if (lastName ==nil || lastName.length ==0)
    {
        [self warnUserWithMessage:STRING(@"Can't create a user with empty last name")];
        return;
    }
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = STRING(@"Creating user");
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        [QuickBloxManager registerUserWithUsername:username andPassword:password andFirstName:firstName andLastName:lastName  andEmail:email withCompletionHandler:^(APIResponse *response) {
            [self.hud hide:YES];
            if(response.error)
            {
                [self warnUserWithMessage:DESC(response.error)];
            }else{
                
                NSString* message = @"registered";
                NSString* senderID = self.usernameTextField.text;
                NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:senderID,@"SenderID",
                          @"dbh.RH.CaRHds.SVC1",@"AppGuid",
                          message,@"Message",
                          @"8E1ED66A-ECB5-422D-B8B8-77FF9E195D7F",@"AppCred", nil];
                [self sendSignalToCarhdsServerWithParams:params];
                
                [self.delegate warnUserWithMessage:[NSString stringWithFormat:STRING(@"User created"),username]];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
            
        }];

    } errorBlock:^(QBResponse *response) {
        [self.hud hide:YES];
        [self warnUserWithMessage:STRING(@"Failed to Start Session")];
    }];
   
}
#pragma mark - Orientation delegates -
-(NSUInteger)supportedInterfaceOrientations
{
    return IS_IPAD? UIInterfaceOrientationMaskAll: UIInterfaceOrientationPortrait;
}


-(BOOL)shouldAutorotate
{
    return IS_IPAD;
}


@end
