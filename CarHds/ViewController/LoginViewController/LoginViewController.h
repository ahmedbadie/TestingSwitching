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

#import "ClientViewController.h"
#define HOST_MEETING_INDEX 0
#define JOIN_MEETING_INDEX 1
@interface LoginViewController : AbstractViewController<UITextFieldDelegate,QBActionStatusDelegate,QBChatDelegate>
@property (weak, nonatomic) IBOutlet UITextField *meetingIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *operationTypeSegmentedControl;


@end
