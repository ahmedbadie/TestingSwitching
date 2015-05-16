//
//  RegisterViewController.m
//  CarHds
//
//  Created by Inova010 on 1/1/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
- (IBAction)buttonClicked:(UIButton *)sender {
    
    
    switch (sender.tag) {
        case 0:
            [self registerUser];
            break;
        case 1:
            [self.delegate warnUserWithMessage:@"Creation Canceled"];
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
        [self warnUserWithMessage:@"Can't create a user with empty username"];
        return;
    }

    if(password==nil||password.length < 8 )
    {
        [self warnUserWithMessage:@"Password should be more than 8 letters"];
        return;
    }
    if(email==nil||email.length ==0 ||![self NSStringIsValidEmail:email])
    {
        [self warnUserWithMessage:@"Invalid email Address"];
        return;
    }
    
    if (firstName ==nil || firstName.length ==0)
    {
        [self warnUserWithMessage:@"Can't create a user with empty first name"];
        return;
    }
    
    
    if (lastName ==nil || lastName.length ==0)
    {
        [self warnUserWithMessage:@"Can't create a user with empty last name"];
        return;
    }
    
    
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Creating user";
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        [QuickBloxManager registerUserWithUsername:username andPassword:password andFirstName:firstName andLastName:lastName  andEmail:email withCompletionHandler:^(APIResponse *response) {
            [self.hud hide:YES];
            if(response.error)
            {
                [self warnUserWithMessage:DESC(response.error)];
            }else{
                [self.delegate warnUserWithMessage:[NSString stringWithFormat:@"User %@ created",username]];
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
            }
            
        }];

    } errorBlock:^(QBResponse *response) {
        [self.hud hide:YES];
        [self warnUserWithMessage:@"Failed to Start Session"];
    }];
   
}
@end
