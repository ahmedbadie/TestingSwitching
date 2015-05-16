//
//  ClientViewController.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "ClientViewController.h"

@interface ClientViewController ()
@property (nonatomic)NSInteger  selectedPageIndex;

@property (nonatomic,strong) NSMutableArray* values;
@property (nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) IBOutlet UIView *cardVotingView;
@property (nonatomic) NSInteger state;
@property (nonatomic) NSInteger maxNumber;
@property (nonatomic) BOOL showingMsg;
@property (nonatomic,strong) NSDate* connectionDate;

#define STATE_CARD_VOTING 0
#define STATE_SELF_CONCLUDE 2
#define STATE_MEETING_CONCLUDE 1
@end

@implementation ClientViewController
@synthesize connectionDate;
- (void)viewDidLoad {
    
    [super viewDidLoad];
    connectionDate = [NSDate date];
    self.maxNumber = 5;
    self.state = STATE_CARD_VOTING;
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
    self.showingMsg = NO;
    self.messages = [NSMutableArray array];
    [MeetingHandler sharedInstance].delegate = self;
    //    self.cardVotingView.frame = self.view.frame;
    
    self.currentIndex = 0;
    //    [self.view addSubview:self.cardVotingView];
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
    NSMutableArray* newMessages = [NSMutableArray array];
    for (QBChatMessage* msg in msgs){
        if([JsonMessageParser isCloseRoomMessage:msg.text] && [msg.datetime compare:connectionDate] == NSOrderedAscending){
            newMessages = [NSMutableArray array];
        }else{
            [newMessages addObject:msg];
        }
    }
    [self.messages addObjectsFromArray:newMessages];
    for(QBChatMessage* msg in newMessages){
        if([Utilities withinRoomLife:msg.datetime]){
            [JsonMessageParser decodeMessage:msg withDelegate:self];
        }
    }
    
}



#pragma mark
#pragma mark - Page View Controller data source -

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [(SingleCardViewController *)viewController index];
    
    if (index == 0) {
        index = self.maxNumber;
    }
    
    // Decrease the index by 1 to return
    index--;
    
    return [self viewControllerForIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [(SingleCardViewController *)viewController index];
    
    index++;
    
    if (index == self.maxNumber) {
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
    //    NSLog(@"Index %ld",(long)index);
}

#pragma mark
#pragma mark - View Controller For Card At Index -
-(SingleCardViewController*) viewControllerForIndex:(NSInteger) index
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SingleCardViewController* controller = [sb instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"SingleCardViewController%@",IS_IPAD? @"IPad":@""]];
    controller.index = index;
    controller.value = [[self.values objectAtIndex:index] boolValue];
    controller.type = self.state;
    controller.delegate = self;
    controller.shouldHandleTap = YES;
    controller.manualImage=NO;
    controller.view.frame = self.view.frame;
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
    if(self.state== STATE_CARD_VOTING){
        [self.values replaceObjectAtIndex:pageIndex withObject:@(!pageOldValue)];
        NSString* msg = [JsonMessageParser cardVoteMessageForCard:pageIndex withValue:!pageOldValue];
        QBChatRoom* chatRoom = [self.chatDialog chatRoom];
        [MeetingHandler sharedInstance].logOut = YES;
        [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:chatRoom save:YES];
    }else if (self.state == STATE_MEETING_CONCLUDE)
    {
        
        UIAlertView* alertView= [[UIAlertView alloc] initWithTitle:@"Meeting Conclusion"
                                                           message:STRING(@"MeetingConclusionConfirmation")
                                                          delegate:self
                                                 cancelButtonTitle:@"Yes"
                                                 otherButtonTitles:@"No", nil];
        
        [alertView show];
        
        self.selectedPageIndex = pageIndex;
    }else if (self.state == STATE_SELF_CONCLUDE)
    {
        
        
        UIAlertView* alertView= [[UIAlertView alloc] initWithTitle:@"Meeting Conclusion"
                                                           message:STRING(@"SelfConclusionConfirmation")
                                                          delegate:self
                                                 cancelButtonTitle:@"Yes"
                                                 otherButtonTitles:@"No", nil];
        
        [alertView show];
        
        self.selectedPageIndex = pageIndex;
        
    }
}

- (IBAction)leaveMeeting:(id)sender {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Leave Meeting";
    NSString* msg = [JsonMessageParser logOutMessageForUser:self.user.login];
    QBChatRoom* chatRoom = [self.chatDialog chatRoom];
    
    [MeetingHandler sharedInstance].logOut = YES;
    [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:chatRoom save:YES];
    [self didLogOut];
    
    
}
#pragma mark - Meeting Handler Delegate -


-(void)didConnectToRoom:(QBChatRoom *)chatRoom
{
    if(chatRoom == nil)
    {
        [self warnUserWithMessage:@"Failed to join room"];
        [self leaveMeeting:self];
        return;
        
    }
    NSString* username = self.user.login;
    NSString* fullname = self.user.fullName;
    
    NSString* jsonMsg= [JsonMessageParser loginMessageWithUsername:username fullname:fullname];
    [[MeetingHandler sharedInstance] sendMessage:jsonMsg toChatRoom:chatRoom save:YES];
}
- (IBAction)valueChanged:(id)sender forEvent:(UIEvent *)event {
    
    NSInteger index = ((UIPageControl*) sender).currentPage;
    SingleCardViewController* card = [self viewControllerForIndex:index];
    [self.pageController setViewControllers:@[card] direction:(self.currentIndex> index) ? UIPageViewControllerNavigationDirectionReverse:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    self.currentIndex = index;
    
}

-(void)didLogOut
{
    [[ChatService shared] leaveRoom:[MeetingHandler sharedInstance].chatRoom];
    [self.hud hide:YES];
    self.pageController.delegate =nil;
    [MeetingHandler sharedInstance].delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - json message parser delegate -
-(void)receivedConclusionSignal
{
    
    NSLog(@"Contribution");
    if(self.state == STATE_CARD_VOTING && !self.showingMsg){
        self.showingMsg = YES;
        UIAlertView* alertView= [[UIAlertView alloc] initWithTitle:@"Meeting Conclusion"
                                                           message:STRING(@"ConcludeMeetingMessage")
                                                          delegate:self
                                                 cancelButtonTitle:@"Yes"
                                                 otherButtonTitles:@"No", nil];
        alertView.tag = 1;
        [alertView show];
        
    }
}

-(void)receivedContributionMessageForType:(CONTRIBUTION_TYPE)type withValue:(CONTRIBUTION_VALUE)val fromMsg:(QBChatMessage *)msg
{
    //    if(val == CONTRIBUTION_TYPE_PERSONAL&& msg.senderID == self.user.ID)
    //    {
    //        [self warnUserWithMessage:@"Meeting ended"];
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //    }
}
-(void) receivedLoginMessageForUsername:(NSString*)username fullname:(NSString *)fullName fromMsg:(QBChatMessage*) msg
{
}
-(void)receivedCardVoteForCard:(NSInteger)cardNo withValue:(BOOL)val fromMsg:(QBChatMessage *)msg{
    
}
-(void)logOutUser:(NSString *)username fromMsg:(QBChatMessage *)msg
{
    
}
-(void)receivedCloseRoom{
    [self warnUserWithMessage:@"Meeting room closed by Host"];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Leave Meeting";
    [JsonMessageParser logOutMessageForUser:self.user.login];
    [self.chatDialog chatRoom];
    
    [MeetingHandler sharedInstance].logOut = YES;
    //    [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:chatRoom save:NO];
    [self didLogOut];
    
}

#pragma mark
#pragma mark - Conclude Menu -
-(void) showConcludeMenuWithIndex:(NSInteger) index
{
    
    
    self.state = index;
    if(self.state == STATE_MEETING_CONCLUDE || self.state == STATE_SELF_CONCLUDE)
    {
        self.maxNumber = 3;
        
        [UIView transitionWithView:self.view
                          duration:1
                           options:UIViewAnimationOptionTransitionCurlUp
                        animations:^{
                            [self.pageController removeFromParentViewController];
                            self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
                            self.pageController.dataSource = self;
                            self.pageController.delegate =self;
                            self.pageController.doubleSided = YES;
                            SingleCardViewController *initialViewController = [self viewControllerForIndex:0];
                            NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
                            [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
                            [self addChildViewController:self.pageController];
                            [[self pageView] addSubview:[self.pageController view]];
                            [self.pageController didMoveToParentViewController:self];
                            [self.pageControl setCurrentPage:0];
                            [self.pageControl setNumberOfPages:3];
                            
                        } completion:^(BOOL finished) {
                            //  Do whatever when the animation is finished
                        }];
        
    }
    
}

#pragma mark
#pragma mark - UIAlertView Delegate -
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag==0){
        self.showingMsg = NO;
        if(buttonIndex == 0)
        {
            if(self.state == STATE_MEETING_CONCLUDE)
            {
                NSString* msg =  [JsonMessageParser contributionMessageWithContributionIndex:CONTRIBUTION_TYPE_MEETING withValue:self.selectedPageIndex];
                QBChatRoom* room = self.chatDialog.chatRoom;
                [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:room save:YES];
                [self showConcludeMenuWithIndex:STATE_SELF_CONCLUDE];
                
            }else if (self.state == STATE_SELF_CONCLUDE)
            {
                NSString* msg =  [JsonMessageParser contributionMessageWithContributionIndex:CONTRIBUTION_TYPE_PERSONAL withValue:self.selectedPageIndex];
                QBChatRoom* room = self.chatDialog.chatRoom;
                [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:room save:YES];
                [self.cardVotingView removeFromSuperview];
                //            [self.view addSubview: self.endView ];
                
                [self.endView setHidden:NO];
            }
            
        }}else if (alertView.tag==1)
        {
            if(buttonIndex==1)
            {
                [self leaveMeeting:nil];
            }else{
                
                [self showConcludeMenuWithIndex:STATE_MEETING_CONCLUDE];
                
            }
        }
}
@end
