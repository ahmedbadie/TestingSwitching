//
//  RegisterViewController.h
//  CarHds
//
//  Created by Inova010 on 1/1/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractViewController.h"
#import "QuickBloxManager.h"
@interface RegisterViewController : AbstractViewController
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic,weak) AbstractViewController* delegate;
@end
