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
#import "HostConcludeViewController.h"
//@protocol HostViewControllerDelegate
@protocol HostViewControllerDelegate <NSObject>

-(void) concludeMeeting:(NSArray*) data ;

@end
@interface HostViewController : AbstractViewController<UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,strong) NSMutableArray* msgs;

@property (nonatomic,strong) UIPageViewController* pageController;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic,strong) NSMutableArray* cardVotes;
-(void) leaveMeeting;
@property (strong, nonatomic) IBOutlet UIView *ipadViewLandscape;
@property (nonatomic,strong) AbstractViewController<HostViewControllerDelegate>* delegate;
@property (weak, nonatomic) IBOutlet UIButton *concludeMeetingButton;
@end
