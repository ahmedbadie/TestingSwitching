//
//  JoinRoomViewControllerHost.h
//  CarHds
//
//  Created by Inova PC 09 on 6/22/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostViewController.h"
#import "ClientViewController.h"
@interface JoinRoomViewControllerHost : AbstractViewController
@property (weak, nonatomic) IBOutlet UITextField *meetingIDTextField;
@property (nonatomic,strong) NSMutableDictionary* users;
@property (strong, nonatomic) NSString *username;
@property (nonatomic)BOOL state;
@property (nonatomic)BOOL isHost;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (nonatomic)BOOL credentialsWasSaved;
@end
