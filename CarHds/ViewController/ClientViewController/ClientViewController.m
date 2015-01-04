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
@property (nonatomic) NSInteger currentIndex;
@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.index = 0;
    [MeetingHandler sharedInstance].logOut = NO;
    // Do any additional setup after loading the view.
    self.values = [NSMutableArray array];
    for(int i=0;i<5;i++)
    {
        [self.values addObject:@YES];
    }
    self.messages = [NSMutableArray array];
    
    // Do any additional setup after loading the view.
    
    self.messages = [NSMutableArray array];
    [MeetingHandler sharedInstance].delegate = self;
    
    
    self.currentIndex = 0;
    
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate =self;
    self.pageController.doubleSided = YES;
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
    [MeetingHandler sharedInstance].delegate = self;
    [[MeetingHandler sharedInstance] connectToChatDialog:self.chatDialog];
   

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
        index = 5;
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
        index=0;
    }
    self.index = index;
    return [self viewControllerForIndex:index];
}




#pragma mark - Page View Controller delegate -

-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSInteger index = ((SingleCardViewController*)[pageViewController.viewControllers firstObject]).index;
    [self.pageControl setCurrentPage:index];
    self.currentIndex = index;
    NSLog(@"Index %d",index);
}

#pragma mark
#pragma mark - View Controller For Card At Index -
-(SingleCardViewController*) viewControllerForIndex:(NSInteger) index
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SingleCardViewController* controller = [sb instantiateViewControllerWithIdentifier:@"SingleCardViewController"];
    controller.index = index;
    controller.value = [[self.values objectAtIndex:index] boolValue];
    controller.type = 0;
    controller.delegate = self;
    controller.shouldHandleTap = YES;
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
    [MeetingHandler sharedInstance].logOut = YES;
    [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:chatRoom];
}

- (IBAction)leaveMeeting:(id)sender {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Leave Meeting";
    NSString* msg = [JsonMessageParser logOutMessageForUser:[MeetingHandler sharedInstance].qbUser.login];
    QBChatRoom* chatRoom = [self.chatDialog chatRoom];
    [MeetingHandler sharedInstance].logOut = YES;
    [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:chatRoom];
    [self didLogOut];
    

}
#pragma mark - Meeting Handler Delegate -

-(void)didConnectToRoom:(QBChatRoom *)chatRoom
{
    NSString* username = [MeetingHandler sharedInstance].qbUser.login;
   NSString* jsonMsg= [JsonMessageParser loginMessageWithUsername:username];
    [[MeetingHandler sharedInstance] sendMessage:jsonMsg toChatRoom:chatRoom];
}
- (IBAction)valueChanged:(id)sender forEvent:(UIEvent *)event {
    
    NSInteger index = ((UIPageControl*) sender).currentPage;
    SingleCardViewController* card = [self viewControllerForIndex:index];
    [self.pageController setViewControllers:@[card] direction:(self.currentIndex> index) ? UIPageViewControllerNavigationDirectionReverse:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    self.currentIndex = index;
    
}

-(void)didLogOut
{
    [[ChatService instance] leaveRoom:[MeetingHandler sharedInstance].chatRoom];
    [self.hud hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
