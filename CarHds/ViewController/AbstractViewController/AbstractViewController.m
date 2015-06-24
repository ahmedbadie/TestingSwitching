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
    [self setNeedsStatusBarAppearanceUpdate];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    if(UIInterfaceOrientationIsPortrait(orientation))
    {
        [self setPortaitMode];
    }else if (UIInterfaceOrientationIsLandscape(orientation))
    {
        
        [self setLandscapeMode];
    }else
    {
        [self setPortaitMode];
    }

}

-(void) setPortaitMode
{

}

-(void) setLandscapeMode
{

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
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

#pragma -
#pragma Server logging methods
-(NSString*)createURLRequestParams:(NSDictionary*)dict{
    NSMutableArray *parts = [NSMutableArray array];
    for (NSString* key in dict) {
        NSString* value = [dict objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding], [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString: @"&"];
}

-(void)sendSignalToCarhdsServerWithParams:(NSDictionary*)params{
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        
        NSString* paramsUrl  = [self createURLRequestParams:params];
        
        //NSLog(@"paramsUrl  %@",paramsUrl);
        
        
        // Old way to create URL
        //NSString * url = [NSString stringWithFormat:@"%@AppGuid=dbh.RH.CaRHds.SVC1&AppCred=8E1ED66A-ECB5-422D-B8B8-77FF9E195D7F&SenderID=%@&ReceiverID=ResourcefulHumans&Message=APISuccessful&MeetingID=%@&CardID=%ld",BASE_URL,senderID,meetingID,(long)cardID];
        NSString * url = [NSString stringWithFormat:@"%@%@",BASE_URL,paramsUrl];
        
        
        NSLog(@"URL :: %@",url);
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        
        NSURLResponse *connectionResponse;
        NSError *connectionError;
        [NSURLConnection sendSynchronousRequest:request returningResponse:&connectionResponse error:&connectionError];
        
        // On the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        
    });
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
-(void)receivedConclusionSignal
{
}

-(void)receivedContributionMessageForType:(CONTRIBUTION_TYPE)type withValue:(CONTRIBUTION_VALUE)val fromMsg:(QBChatMessage *)msg
{
}
-(void) receivedLoginMessageForUsername:(NSString*)username fullname:(NSString *)fullName fromMsg:(QBChatMessage*) msg
{
}
-(void)receivedCardVoteForCard:(NSInteger)cardNo withValue:(BOOL)val fromMsg:(QBChatMessage *)msg{

}
-(void)logOutUser:(NSString *)username fromMsg:(QBChatMessage *)msg
{

}

-(void) receivedCloseRoom{
    
}
#pragma mark
#pragma mark - UITextField Delegate -

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Orientation - 
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



-(BOOL)shouldAutorotate
{
    
    return YES;
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

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
@end
