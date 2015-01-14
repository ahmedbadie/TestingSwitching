//
//  HostViewController.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "HostViewController.h"
#import "SingleCardViewController.h"
@interface HostViewController ()
@property (weak, nonatomic) IBOutlet UIView *IphoneView;
@property (weak, nonatomic) IBOutlet UIView *IpadView;
@property (weak, nonatomic) IBOutlet UIView *card0View;
@property (weak, nonatomic) IBOutlet UIView *card1View;
@property (weak, nonatomic) IBOutlet UIView *card2View;
@property (weak, nonatomic) IBOutlet UIView *card3View;
@property (weak, nonatomic) IBOutlet UIView *card4View;
@property (weak, nonatomic) IBOutlet UILabel *numberOfParticipants;
@property (weak, nonatomic) IBOutlet UIView *concludeIPadView;
@property (nonatomic,strong) NSMutableArray* origins;
@property (strong,nonatomic) NSMutableArray* conclusionCards;
@property (nonatomic,strong) NSMutableDictionary* users;
@property (nonatomic,strong) NSMutableArray* viewControllers;
@property (nonatomic,strong) NSMutableDictionary* conclusionDictionary;
@property (weak, nonatomic) IBOutlet UIView *topLeftViewConclude;
@property (weak, nonatomic) IBOutlet UIView *topMiddleViewConclude;
@property (weak, nonatomic) IBOutlet UIView *topRightViewConclude;
@property (weak, nonatomic) IBOutlet UIView *BottomLeftViewConclude;
@property (weak, nonatomic) IBOutlet UIView *BottomMiddleViewConclude;
@property (weak, nonatomic) IBOutlet UIView *BottomRightViewConclude;
@property (nonatomic) BOOL  canConclude ;
@property (nonatomic) BOOL concludeMeetingOn;
@property (weak, nonatomic) IBOutlet UILabel *tlLabel;
@property (weak, nonatomic) IBOutlet UILabel *tmLabel;
@property (weak, nonatomic) IBOutlet UILabel *trLabel;
@property (weak, nonatomic) IBOutlet UILabel *blLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmLabel;
@property (weak, nonatomic) IBOutlet UILabel *brLabel;

@property (weak, nonatomic) IBOutlet UIButton *leaveMeetingButton;

@end

@implementation HostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgs = [NSMutableArray array];
    self.users = [NSMutableDictionary dictionary];
    [MeetingHandler sharedInstance].delegate = self;
    self.canConclude= YES;
    self.concludeMeetingOn = NO;
    if(IS_IPAD)
    {
        [self.IphoneView removeFromSuperview];
        [self.IpadView setHidden:NO];
        UIStoryboard* storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NSArray* cardsViews = @[self.card1View,self.card2View,self.card3View,self.card4View,self.card0View];
        self.viewControllers = [NSMutableArray arrayWithCapacity:[cardsViews count]];
        for(int i=0 ;i<[cardsViews count] ; i++)
            [self.viewControllers addObject:@(YES)];
        for(UIView* view in cardsViews)
        {
            SingleCardViewController* card= [storyBoard instantiateViewControllerWithIdentifier:@"SingleCardViewController2"];
            card.index = view.tag;
            card.value = YES;
            card.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            card.shouldHandleTap = NO;
            [self addChildViewController:card];
            [view addSubview:card.view];
            card.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [card didMoveToParentViewController:self];
            self.numberOfParticipants.layer.borderWidth=1.0f;
            [self.numberOfParticipants.layer setCornerRadius:self.numberOfParticipants.frame.size.width/2];
            self.numberOfParticipants.clipsToBounds = YES;
            
            [self.viewControllers replaceObjectAtIndex:card.index withObject:card];
        }
        
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        [self.numberOfParticipants setText:[NSString stringWithFormat:@"%d",[[self.users allKeys] count]]];
        [self.view addSubview:self.IpadView];
        //        if(UIInterfaceOrientationIsPortrait(orientation))
        //        {
        //            [self setPortaitMode];
        //        }else if (UIInterfaceOrientationIsLandscape(orientation))
        //        {
        //
        //            [self setLandscapeMode];
        //            }
    }else{
        [self.IphoneView setHidden:NO];
        [self.IpadView removeFromSuperview];
    }
    
    
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        [self setPortaitMode];
    }else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        
        [self setLandscapeMode];
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    //       if(UIInterfaceOrientationIsPortrait(orientation))
    //    {
    //        [self setPortaitMode];
    //    }else if (UIInterfaceOrientationIsLandscape(orientation))
    //    {
    //
    //        [self setLandscapeMode];
    //    }
    
    
    
    
#warning Uncommint the 2 lines
    self.title = self.chatDialog.name;
    
    [[MeetingHandler sharedInstance] connectToChatDialog:self.chatDialog];
    
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    
}
- (IBAction)buttonPressed:(UIButton *)sender {
    
    switch (sender.tag) {
        case 0:
            [self leaveMeeting];
            break;
        case 1:
            [self showFinalStatistics];
            break;
        default:
            break;
    }
}


-(void) showFinalStatistics
{
    [self performSegueWithIdentifier:HOST_STATISTICS_SEGUE sender:self];
}
-(void) leaveMeeting
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.labelText = @"Leave Meeting";
    //    NSString* msg = [JsonMessageParser logOutMessageForUser:[MeetingHandler sharedInstance].qbUser.login];
    //    QBChatRoom* chatRoom = [self.chatDialog chatRoom];
    [MeetingHandler sharedInstance].logOut = YES;
    [self didLogOut];
    
}
-(void)didLogOut
{
    [[ChatService instance] leaveRoom:[MeetingHandler sharedInstance].chatRoom];
    [self.hud hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didConnectToRoom:(QBChatRoom *)chatRoom
{
    if(chatRoom == nil)
    {
        [self warnUserWithMessage:@"Failed to join room"];
        [self leaveMeeting];
        return;
        
    }else{
        NSString* msg = [JsonMessageParser dummyMessage];
        QBChatRoom* room = chatRoom;
        [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:room];
        [NSTimer scheduledTimerWithTimeInterval:HOST_DUMMY_MESSAGE_INTERVAL
                                         target:self
                                       selector:@selector(sendDummyMessage)
                                       userInfo:nil
                                        repeats:YES];
    }
    
}

-(void) sendDummyMessage
{
    NSString* msg = [JsonMessageParser dummyMessage];
    QBChatRoom* room = self.chatDialog.chatRoom;
    [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:room];
}

#
- (IBAction)sendMessage:(id)sender {
    
}

#pragma mark
#pragma mark - Meeting Handler Delegate Methods -

-(void)didReciveMessages:(NSArray *)msgs
{
    [self.msgs addObjectsFromArray:msgs];
    for(QBChatMessage* msg in msgs){
        if([Utilities withinRoomLife:msg.datetime]){
            [JsonMessageParser decodeMessage:msg withDelegate:self];
        }
    }
}

#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


-(void)receivedCardVoteForCard:(NSInteger)cardNo withValue:(BOOL)val fromMsg:(QBChatMessage *)msg
{
    NSUInteger userId = msg.senderID;
    NSMutableDictionary* dictionary = [self.users objectForKey:@(userId)];
    if(dictionary==nil)
    {
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:[NSString stringWithFormat:@"%u",userId] forKey:MESSAGE_LOGIN_USERNAME];
        NSMutableArray* cards = [NSMutableArray array];
        for(int i=0;i<5;i++)
            [cards addObject:@YES];
        [dictionary setObject:cards forKey:@"cards"];
        [self.users setObject:dictionary forKey:@(userId)];
    }
    NSMutableArray* cards = [dictionary objectForKey:@"cards"];
    [cards replaceObjectAtIndex:cardNo withObject:@(val)];
    SingleCardViewController* vc = [self.viewControllers objectAtIndex:cardNo];
    BOOL value = YES;
    
    NSArray* allKeys = [self.users allKeys];
    
    for(NSString* key in allKeys)
    {
        value = value & [[[[self.users objectForKey:key] objectForKey:@"cards"] objectAtIndex:cardNo] boolValue];
    }
    if(vc.value != value){
        vc.value = value;
        [vc setImageWithAnimation:YES];
    }
    
}
-(void)receivedConclusionSignal
{
    [self.hud hide:YES];
    self.canConclude = NO;
    [self warnUserWithMessage:@"Meeting Conclusion started"];
    if(!self.concludeMeetingOn)
    {
        self.concludeMeetingOn = YES;
        [self showConcludeMeetingView];
    }
    
    
}

-(void)receivedContributionMessageForType:(CONTRIBUTION_TYPE)type withValue:(CONTRIBUTION_VALUE)val fromMsg:(QBChatMessage *)msg
{
    NSUInteger key = msg.senderID;
    NSMutableArray* array = [self.conclusionDictionary objectForKey:@(key)];
    
    if(array)
    {
        if([[array objectAtIndex:type] integerValue]!=-1)
        {
            HostConcludeCardViewController* oldCard = [self.conclusionCards objectAtIndex:(type*3 + [[array objectAtIndex:type] integerValue])];
            [oldCard removeVoter:key];
        }
        int index = (type*3) + val;
        HostConcludeCardViewController* newCard = [self.conclusionCards objectAtIndex:index];
        [newCard addVote:[[self.users objectForKey:@(key)] objectForKey:MESSAGE_LOGIN_USERNAME] :key];
        
        
        [array replaceObjectAtIndex:type withObject:@(val)];
        
    }
    NSMutableArray* temp = [NSMutableArray array];
    for(HostConcludeCardViewController* card in self.conclusionCards)
    {
        NSInteger count = [self getCardsCountForType:card.type andIndex:card.index];
        card.cardVotes = count;
        [card.cardCountLabel setText:[NSString stringWithFormat:@"%d",count]];
        [card reloadScreen];
        [temp addObject:card];
    }
    
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: NO];
    NSArray* temp2=  [temp sortedArrayUsingDescriptors: [NSArray arrayWithObject: sortOrder]];
    NSArray* views = @[self.topLeftViewConclude,self.topMiddleViewConclude,self.topRightViewConclude,self.BottomLeftViewConclude,self.BottomMiddleViewConclude,self.BottomRightViewConclude];
    int index = 0;
    CGSize size = self.topLeftViewConclude.frame.size;
    for(HostConcludeCardViewController* card in temp2)
    {
        CGPoint origin = [[self.origins objectAtIndex:index] CGPointValue];
        
        UIView* superView = [card.view superview];
        if(superView.frame.origin.x != origin.x)
        {
            
            [UIView transitionWithView:self.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionNone
                            animations:^{
                                
                                superView.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
                            } completion:^(BOOL finished) {
                                //  Do whatever when the animation is finished
                            }];
            
        }
        index++;
        
    }
}

-(void)receivedLoginMessageForUsername:(NSString *)username fromMsg:(QBChatMessage *)msg
{
    NSUInteger userId = msg.senderID;
    
    NSMutableDictionary* dictionary = [self.users objectForKey:@(userId)];
    
    if(dictionary==nil)
    {
        dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:username forKey:MESSAGE_LOGIN_USERNAME];
        NSMutableArray* cards = [NSMutableArray array];
        for(int i=0;i<5;i++)
            [cards addObject:@YES];
        [dictionary setObject:cards forKey:@"cards"];
        [self.users setObject:dictionary forKey:@(userId)];
    }
    [self.numberOfParticipants setText:[NSString stringWithFormat:@"%d",[[self.users allKeys] count]]];
    
}

-(void)logOutUser:(NSString *)username fromMsg:(QBChatMessage *)msg
{
    [self.users removeObjectForKey:@(msg.senderID)];
    
    for(int i=0;i<5;i++)
    {
        SingleCardViewController* vc = [self.viewControllers objectAtIndex:i];
        BOOL value = YES;
        
        NSArray* allKeys = [self.users allKeys];
        [self.numberOfParticipants setText:[NSString stringWithFormat:@"%d",[[self.users allKeys] count]]];
        
        for(NSString* key in allKeys)
        {
            value = value & [[[[self.users objectForKey:key] objectForKey:@"cards"] objectAtIndex:i] boolValue];
        }
        if(vc.value != value){
            vc.value = value;
            [vc setImageWithAnimation:YES];
        }
        
    }
    
}

- (IBAction)concludeMeeting:(id)sender {
    NSLog(@"Conclude Meeting");
    if(self.canConclude){
//        if([[self.users allKeys] count] <1)
//        {
//            [self warnUserWithMessage:STRING(@"NeedUsersMsg")];
//            return;
//        }
        UIAlertView* alertView= [[UIAlertView alloc] initWithTitle:@"Conclude Meeting"
                                                           message:STRING(@"ConcludeMeetingConfirmation")
                                                          delegate:self
                                                 cancelButtonTitle:@"Yes"
                                                 otherButtonTitles:@"No", nil];
        
        [alertView show];
        
    }
}
#pragma mark
#pragma mark - UIAlertView Delegate -
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        self.canConclude = NO;
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Preparing for meeting conclusion";
        NSString* msg = [JsonMessageParser broadcastContributionSignal];
        QBChatRoom* room = self.chatDialog.chatRoom;
        [[MeetingHandler sharedInstance] sendMessage:msg toChatRoom:room];
        
    }
}
#pragma mark
#pragma mark - Conclude Meeting -

-(void) prepareData
{
    
    
    self.cardVotes= [NSMutableArray array];
    for(int i=0 ;i < 6; i++ )
    {
        [self.cardVotes addObject:[NSMutableArray array]];
    }
    
    
    for(NSString* key in [self.users allKeys])
    {
        NSArray* votes= [self.users objectForKey:key];
        
        for(int j =0 ;j<[votes count];j++)
        {
            if([votes[j] integerValue]!=-1)
            {
                NSUInteger value= ((int)(j/3)) + [votes[j] integerValue] ;
                [[self.cardVotes objectAtIndex:value ]addObject:key];
            }
        }
    }
    
    
    
}

-(void)showConcludeMeetingView
{
    [self.delegate concludeMeeting:@[self.users]];
}


-(NSInteger) getCardsCountForType:(CONTRIBUTION_TYPE) type andIndex:(NSInteger) index
{
    NSInteger count = 0;
    
    NSArray* keys = [self.conclusionDictionary allKeys];
    
    for(NSString* key in keys)
    {
        NSArray* values = [self.conclusionDictionary objectForKey:key];
        if([[values objectAtIndex:type] integerValue]==index)
        {
            count++;
        }
    }
    return count;
}
#pragma mark - Orientation -

-(void) setLandscapeMode
{
    
    CGFloat factor = 0.75;
    CGFloat xOffset = 101;
    CGSize size = CGSizeMake(275*factor, 470*factor);
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        
                        self.card1View.frame = CGRectMake(xOffset, 20, size.width,size.height);
                        self.card2View.frame = CGRectMake(1024-xOffset-(size.width), 20,size.width,size.height);
                        self.card3View.frame = CGRectMake(1024-xOffset-(size.width), 768-20-(size.height),size.width,size.height);
                        self.card4View.frame = CGRectMake(xOffset, 768-20-(size.height), size.width,size.height);
                        self.card0View.frame = CGRectMake((1024/2)-(size.width/2), (768/2)-(size.height/2), size.width,size.height);
                        self.card0View.center = self.IpadView.center;
                        self.numberOfParticipants.frame = CGRectMake(xOffset-(40), 20, 80, 80);
                        self.concludeMeetingButton.frame = self.numberOfParticipants.frame;
                        for(UIViewController* card in self.viewControllers)
                            card.view.frame = CGRectMake(0, 0, size.width, size.height);
                    } completion:^(BOOL finished) {
                        //  Do whatever when the animation is finished
                    }];
    
    
    NSLog(@"Center card frame = %f,%f,%f,%f",self.card0View.frame.origin.x,self.card0View.frame.origin.y,self.card0View.frame.size.width,self.card0View.frame.size.height);
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}
-(void) setPortaitMode
{
    CGFloat factor = 1;
    CGSize size = CGSizeMake(275*factor, 470*factor);
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionNone
                    animations:^{
                        
                        self.card1View.frame = CGRectMake(20, 20, 275, 470);
                        self.card2View.frame = CGRectMake(473, 20, 275, 470);
                        self.card3View.frame = CGRectMake(473, 534, 275, 470);
                        self.card4View.frame = CGRectMake(20, 534, 275, 470);
                        self.card0View.frame = CGRectMake(247, 277, 275, 470);
                        self.numberOfParticipants.frame = CGRectMake(15, 23, 80, 80);
                        self.concludeMeetingButton.frame = self.numberOfParticipants.frame;

                        for(UIViewController* card in self.viewControllers)
                            card.view.frame = CGRectMake(0, 0, size.width, size.height);
                        
                    } completion:^(BOOL finished) {
                        //  Do whatever when the animation is finished
                    }];
    
    
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIDeviceOrientation toInterfaceOrientation = [[UIDevice currentDevice] orientation];
    switch (toInterfaceOrientation) {
        case UIDeviceOrientationPortrait:
            [self setPortaitMode];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [self setLandscapeMode];
            break;
        case UIDeviceOrientationLandscapeRight:
            [self setLandscapeMode];
            break;
        default:
            break;
    }
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    if(self.canConclude)
        return UIInterfaceOrientationMaskAll;
    
    UIInterfaceOrientation orientationStatusBar =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientationStatusBar != UIInterfaceOrientationPortrait) {
        return UIInterfaceOrientationMaskAll;
    }
    //this line not permit rotate is the viewController is portrait
    return UIInterfaceOrientationPortrait;
}


-(BOOL)shouldAutorotate
{
    
    UIInterfaceOrientation orientationStatusBar =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientationStatusBar != UIInterfaceOrientationPortrait) {
        return YES;
    }
    //this line not permit rotate is the viewController is portrait
    return self.canConclude;
    
}
@end
