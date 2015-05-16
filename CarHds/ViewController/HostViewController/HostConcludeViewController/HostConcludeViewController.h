//
//  HostConcludeViewController.h
//  CarHds
//
//  Created by Inova010 on 1/13/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "AbstractNavigationController.h"
#import "HostConcludeCardViewController.h"
@interface HostConcludeViewController : AbstractViewController

@property(nonatomic,strong) AbstractViewController* delegate;
@property (strong,nonatomic) NSMutableArray* conclusionCards;
@property (nonatomic,strong) NSMutableDictionary* users;
@property (nonatomic,strong) NSMutableArray* origins;
@property (nonatomic,strong) NSMutableDictionary* conclusionDictionary;
@property (weak, nonatomic) IBOutlet UIView *topLeftViewConclude;
@property (weak, nonatomic) IBOutlet UIView *topMiddleViewConclude;
@property (weak, nonatomic) IBOutlet UIView *topRightViewConclude;
@property (weak, nonatomic) IBOutlet UIView *BottomLeftViewConclude;
@property (weak, nonatomic) IBOutlet UIView *BottomMiddleViewConclude;
@property (weak, nonatomic) IBOutlet UIView *BottomRightViewConclude;
@property (weak, nonatomic) IBOutlet UIView *concludeIPadView;
@property (weak, nonatomic) IBOutlet UIButton *shareScreenShotButton;
@end
