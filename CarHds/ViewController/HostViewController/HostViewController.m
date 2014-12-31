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

@property (nonatomic,strong) NSMutableDictionary* users;
@property (nonatomic,strong) NSMutableArray* viewControllers;
@end

@implementation HostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgs = [NSMutableArray array];
    self.users = [NSMutableDictionary dictionary];
    [MeetingHandler sharedInstance].delegate = self;
   
    [QBChat instance].delegate = [MeetingHandler sharedInstance];
    
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
            SingleCardViewController* card= [storyBoard instantiateViewControllerWithIdentifier:@"SingleCardViewController"];
            card.index = view.tag;
            card.value = YES;
            card.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            card.shouldHandleTap = NO;
            [self addChildViewController:card];
            [view addSubview:card.view];
            [card didMoveToParentViewController:self];
            [self.viewControllers replaceObjectAtIndex:card.index withObject:card];
        }
        
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







#
- (IBAction)sendMessage:(id)sender {
    
  }

#pragma mark
#pragma mark - Meeting Handler Delegate Methods -

-(void)didReciveMessages:(NSArray *)msgs
{
    [self.msgs addObjectsFromArray:msgs];
    for(QBChatMessage* msg in msgs)
        [JsonMessageParser decodeMessage:msg withDelegate:self];

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
//    vc.value = vc.value & val;
    BOOL value = YES;
    
    NSArray* allKeys = [self.users allKeys];
    
    for(NSString* key in allKeys)
    {
        value = value & [[[[self.users objectForKey:key] objectForKey:@"cards"] objectAtIndex:cardNo] boolValue];
    }
    vc.value = value;
    [vc setImageWithAnimation:YES];
}

-(void)receivedConclusionSignal
{

}

-(void)receivedContributionMessageForType:(CONTRIBUTION_TYPE)type withValue:(CONTRIBUTION_VALUE)val fromMsg:(QBChatMessage *)msg
{
    
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
    
}

@end
