//
//  ForgetPasswordViewController.m
//  CarHds
//
//  Created by Inova010 on 1/14/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "ForgetPasswordViewController.h"

@interface ForgetPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *entryType;

@end

@implementation ForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view sendSubviewToBack:self.backgroundImage];
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


- (IBAction)resetPassword:(id)sender {
       NSString* text = [self.usernameTextField text];
    NSInteger type = self.entryType.selectedSegmentIndex;
    if(text==nil || text.length==0)
    {
        [self warnUserWithMessage:[NSString stringWithFormat:@"%@ Missing",type==0? @"Username":@"Email"]];
        return;
    }
    
    
    if([self.entryType selectedSegmentIndex]==0)
    {
                [self forgetPasswordForType:0 andText:text];

        
    }else {
    
        if(![self NSStringIsValidEmail:text])
        {
            [self warnUserWithMessage:@"Invalid Email Address"];
            return;
            
        }else{
          
            [self forgetPasswordForType:1 andText:text];
            
        }
    }
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
- (void)forgetPasswordForType:(NSInteger) type andText:(NSString*) text {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Reset Password";

    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        
        
        if(type==1)
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


@end
