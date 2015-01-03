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
    NSString* username = [self.usernameTextField text];
//    NSString* email = [self.emailTextField text];
    NSString* password =[self.passwordTextField text];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Creating user";
    [QuickBloxManager registerUserWithUsername:username andPassword:password withCompletionHandler:^(APIResponse *response) {
        [self.hud hide:YES];
        if(response.error)
        {
            [self warnUserWithMessage:[response.error description]];
        }else{
            [self.delegate warnUserWithMessage:[NSString stringWithFormat:@"User %@ created",username]];
             
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
        
    }];

}
@end