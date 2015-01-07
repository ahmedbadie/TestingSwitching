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
            [card didMoveToParentViewController:self];
            self.numberOfParticipants.layer.borderWidth=1.0f;
            [self.numberOfParticipants.layer setCornerRadius:self.numberOfParticipants.frame.size.width/2];
            self.numberOfParticipants.clipsToBounds = YES;
            
            [self.viewControllers replaceObjectAtIndex:card.index withObject:card];
        }
        [self.view addSubview:self.IpadView];
        [self.numberOfParticipants setText:[NSString stringWithFormat:@"%d",[[self.users allKeys] count]]];
        
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    // Set keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.title = self.chatDialog.name;
    
    [[MeetingHandler sharedInstance] connectToChatDialog:self.chatDialog];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)leaveMeeting:(id)sender {
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
        [self leaveMeeting:self];
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
        [array replaceObjectAtIndex:type withObject:@(val)];
    }
    
    for(CardViewController* card in self.conclusionCards)
    {
        NSInteger count = [self getCardsCountForType:card.type andIndex:card.index];
        card.cardVotes = count;
        [card setValueLabel:count];
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
           
         UIAlertView* alertView= [[UIAlertView alloc] initWithTitle:@"NO!"
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
-(void)showConcludeMeetingView
{
    NSArray* participants = [self.chatDialog occupantIDs];
    NSLog(@"%d",[participants count]);

    self.conclusionCards = [NSMutableArray array];
    UIStoryboard* storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSArray* views = @[self.topLeftViewConclude,self.topMiddleViewConclude,self.topRightViewConclude,self.BottomLeftViewConclude,self.BottomMiddleViewConclude,self.BottomRightViewConclude];
    int index =0 ;
    for(int i=0;i<[views count];i++)
        [self.conclusionCards addObject:@2];
    
    self.conclusionDictionary = [NSMutableDictionary dictionary];
    
    NSArray* users = [self.users allKeys];
    
    for(NSString* user in users)
    {
        NSMutableArray* array = [NSMutableArray arrayWithObjects:@-1,@-1, nil];
        [self.conclusionDictionary setObject:array forKey:user];
        
    }
    for(UIView* view in views)
    {
        CardViewController* card = [storyBoard instantiateViewControllerWithIdentifier:@"HostConclusionCard"];
        card.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
        [self addChildViewController:card];
        [view addSubview:card.view];
        [card didMoveToParentViewController:self];
        NSInteger type = index / 3;
        NSInteger tIndex = index %3;
        card.type = type;
        card.index = tIndex;
        card.cardVotes = 0;
        [card setImage];
        self.numberOfParticipants.layer.borderWidth=1.0f;
        [self.numberOfParticipants.layer setCornerRadius:self.numberOfParticipants.frame.size.width/2];
        self.numberOfParticipants.clipsToBounds = YES;
        [self.conclusionCards replaceObjectAtIndex:index withObject:card];
        index++;
    }
    [UIView transitionWithView:self.view
                      duration:0.4
                       options:UIViewAnimationOptionTransitionCurlUp
                    animations:^{
                        
                        [self.view addSubview:self.concludeIPadView];
                        [self.IpadView removeFromSuperview];
                    } completion:^(BOOL finished) {
                        //  Do whatever when the animation is finished
                    }];
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
@end
