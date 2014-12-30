//
//  ClientViewController.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "ClientViewController.h"

@interface ClientViewController ()

@property (nonatomic,strong) NSMutableArray* values;
@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
    // Do any additional setup after loading the view.
    self.values = [NSMutableArray array];
    for(int i=0;i<5;i++)
    {
        [self.values addObject:@YES];
    }
    self.messages = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    
    self.messages = [NSMutableArray array];
    
       self.handler = [[MeetingHandler alloc]init];
    self.handler.delegate = self;
    self.handler.chatDialog =self.chatDialog;
    self.handler.user = self.user;
    
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate =self;
    SingleCardViewController *initialViewController = [self viewControllerForIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [self addChildViewController:self.pageController];
    [[self pageView] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        
            self.title = self.chatDialog.name;
    [self.handler connectToChatDialog:self.chatDialog];
   

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    
   }

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
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

//- (IBAction)sendMessage:(id)sender {
//    
//    if(self.messageTextField.text.length == 0){
//        return;
//    }
//    
//    // create a message
//    [self.handler sendMessage:[self.messageTextField text] toChatRoom:self.chatRoom];
//    // Reload table
//    [self.tableView reloadData];
//    if(self.messages.count > 0){
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
//    
//    // Clean text field
//    [self.messageTextField setText:nil];
//
//}




#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




#pragma mark
#pragma mark - Meeting Handler Delegate Methods -

-(void)didReciveMessages:(NSArray *)msgs
{
    [self.messages addObjectsFromArray:msgs];

}



#pragma mark 
#pragma mark - Page View Controller data source -

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [(SingleCardViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerForIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [(SingleCardViewController *)viewController index];
    
    index++;
    
    if (index == 5) {
        return nil;
    }
    self.index = index;
    return [self viewControllerForIndex:index];
}




#pragma mark - Page View Controller delegate -

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSInteger index = ((SingleCardViewController*)[pageViewController.viewControllers firstObject]).index;
    [self.pageControl setCurrentPage:index];
    NSLog(@"Index %d",index);
}

#pragma mark
#pragma mark - View Controller For Card At Index -
-(SingleCardViewController*) viewControllerForIndex:(NSInteger) index
{
    
    SingleCardViewController* controller = [[SingleCardViewController alloc]init];
    controller.index = index;
    controller.value = [[self.values objectAtIndex:index] boolValue];
    controller.type = 0;
    controller.delegate = self;
    return controller;
}



#pragma mark

-(void)setIndex:(NSInteger)index
{
//    [self.pageControl setCurrentPage:index];
//    NSLog(@"select %d",index);
}

-(void) changePageState:(NSInteger) pageIndex :(BOOL) pageOldValue
{
    [self.values replaceObjectAtIndex:pageIndex withObject:@(!pageOldValue)];
    NSString* msg = [JsonMessageParser cardVoteMessageForCard:pageIndex withValue:!pageOldValue];
    QBChatRoom* chatRoom = [self.chatDialog chatRoom];
    [self.handler sendMessage:msg toChatRoom:chatRoom];
}
@end
