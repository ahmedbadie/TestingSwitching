//
//  HostViewController.h
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "AbstractViewController.h"
#import "ChatService.h"
#import "ChatMessageTableViewCell.h"
#import "CardViewController.h"
#import "HostConcludeCardViewController.h"
@interface HostViewController : AbstractViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) NSMutableArray* msgs;

@property (nonatomic,strong) UIPageViewController* pageController;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic,strong) NSMutableArray* cardVotes;

@end
