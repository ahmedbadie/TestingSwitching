//
//  AbstractViewController.m
//  CaRHds
//
//  Created by Inova010 on 12/29/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "AbstractViewController.h"

@interface AbstractViewController ()

@end

@implementation AbstractViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

-(void) warnUserWithMessage:(NSString*) msg
{
    MBProgressHUD *mbHud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    
    mbHud.detailsLabelFont = [UIFont fontWithName:@"Helvetica Regular" size:16];
    // Configure for text only and offset down
    mbHud.mode = MBProgressHUDModeText;
    mbHud.detailsLabelText = msg;
    mbHud.margin = 10.f;
    mbHud.removeFromSuperViewOnHide = YES;
    
    [mbHud hide:YES afterDelay:2];
}


#pragma mark - Meeting Handler Delegate -

-(void)didReciveMessages:(NSArray *)msgs
{
    
}

-(void)didConnectToRoom:(QBChatRoom *)chatRoom
{

}

-(void)didLogOut
{
    
}
#pragma mark - json message parser delegate -
-(void)receivedCardVoteForCard:(NSInteger)cardNo withValue:(BOOL)val
{
}

-(void)receivedConclusionSignal
{

}

-(void)receivedContributionMessageForType:(CONTRIBUTION_TYPE)type withValue:(CONTRIBUTION_VALUE)val fromUserID:(NSUInteger)userID
{

}

-(void)receivedLoginMessageForUsername:(NSString *)username andUserID:(NSUInteger)userID
{

}


@end
