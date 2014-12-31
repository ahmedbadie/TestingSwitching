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
@interface HostViewController : AbstractViewController<UITextFieldDelegate>
@property (nonatomic,strong) NSMutableArray* msgs;

@property (nonatomic,strong) UIPageViewController* pageController;
@property (weak, nonatomic) IBOutlet UIView *pageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@end
