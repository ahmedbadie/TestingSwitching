//
//  ClientViewController.h
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "AbstractViewController.h"
#import "ChatMessageTableViewCell.h"
#import "SingleCardViewController.h"
@interface ClientViewController : AbstractViewController<UITextFieldDelegate,UIPageViewControllerDataSource,SingleCardViewControllerDelegate,UIPageViewControllerDelegate>
@property (nonatomic,strong) UIPageViewController* pageController;
@property (nonatomic,strong) MBProgressHUD* hud;
@property (nonatomic,strong) NSMutableArray* messages;
@property (nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (strong, nonatomic) IBOutlet UIView *endView;

@end
