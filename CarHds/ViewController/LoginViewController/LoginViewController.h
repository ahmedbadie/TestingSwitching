//
//  LoginViewController.h
//  CaRHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "AbstractViewController.h"
#import "QuickBloxManager.h"
#import "HostViewController.h"
#import "NSDictionary_JSONExtensions.h"
#import "RegisterViewController.h"
#import "ClientViewController.h"
#import "JoinRoomViewControllerClient.h"
#import "JoinRoomViewControllerHost.h"
#define HOST_MEETING_INDEX 0
#define JOIN_MEETING_INDEX 1
@interface LoginViewController : AbstractViewController<UITextFieldDelegate,QBActionStatusDelegate,QBChatDelegate,HostViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel * titleLabel;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@property (nonatomic,strong) NSMutableDictionary* users;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIView *fieldsView;

@end
