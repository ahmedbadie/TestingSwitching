//
//  HostConcludeViewController.m
//  CarHds
//
//  Created by Inova010 on 1/13/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "HostConcludeViewController.h"
#import "HostViewController.h"
@interface HostConcludeViewController ()

@end

@implementation HostConcludeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showConcludeMeetingView];
    
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (IBAction)leaveMeating:(id)sender {
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


-(void)showConcludeMeetingView
{
    self.origins = [NSMutableArray array];
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
        
        [self.origins addObject:[NSValue valueWithCGPoint:view.frame.origin]];
        
        HostConcludeCardViewController* card = [storyBoard instantiateViewControllerWithIdentifier:HOST_CONCLUDE_CONTROLLER];
        NSInteger type = index / 3;
        NSInteger tIndex = index %3;
        card.type = type;
        card.index = tIndex;
        card.cardVotes = 0;
        [self addChildViewController:card];
        [view addSubview:card.view];
        CGSize size = view.frame.size;
        card.view.frame = CGRectMake(0, 0, size.width, size.height);
        [card didMoveToParentViewController:self];
        [card reloadScreen];
        
        [self.conclusionCards replaceObjectAtIndex:index withObject:card];
        
        index++;
    }
    
    //        [UIView transitionWithView:self.view
    //                          duration:1.0
    //                           options:UIViewAnimationOptionTransitionFlipFromBottom
    //                        animations:^{
    //
    //                            [self.view addSubview:self.concludeIPadView];
    //                        } completion:^(BOOL finished) {
    //                            //  Do whatever when the animation is finished
    //                        }];
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

-(void)didReciveMessages:(NSArray *)msgs
{
    for(QBChatMessage* msg in msgs){
        if([Utilities withinRoomLife:msg.datetime]){
            [JsonMessageParser decodeMessage:msg withDelegate:self];
        }
    }
}

@end
