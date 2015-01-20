//
//  HostConcludeCardViewController.m
//  CarHds
//
//  Created by Inova010 on 1/11/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "HostConcludeCardViewController.h"

@interface HostConcludeCardViewController ()
@property(nonatomic,strong) NSMutableArray* cards;
@end

@implementation HostConcludeCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.voters = [NSMutableDictionary dictionary];
    self.votersIDs = [NSMutableArray array];
    [self.cardCountLabel setText:@"0"];
    self.cardCountLabel.layer.cornerRadius = self.cardCountLabel.frame.size.width/2;
    self.cardCountLabel.clipsToBounds = YES;
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

-(void)addVote:(NSString *)userName :(NSUInteger)userId
{
    [self.votersIDs addObject:@(userId)];
    [self.voters setObject:userName forKey:@(userId)];
}

-(void)removeVoter:(NSUInteger)userId
{

    [self.voters removeObjectForKey:@(userId)];
    [self.votersIDs removeObject:@(userId)];
}

#define LabelTag 10
-(void)reloadScreen
{
    for(UIView* view in self.view.subviews)
    {
        if(view.tag !=LabelTag)
            [view removeFromSuperview];
        
    }
    UIStoryboard* storyBoard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];

    NSUInteger offset = 20;
    UIInterfaceOrientation orientation = self.parentViewController.interfaceOrientation;
    
#define MAX_CARDS(orientation)  UIInterfaceOrientationIsPortrait(orientation)? 7 : 3
    int startIndex = 0;
    NSInteger maxCards = MAX_CARDS(orientation);
    if(self.cardVotes>maxCards)
    {
        startIndex = self.cardVotes - maxCards;
    }
    for(int i = startIndex ;i<self.cardVotes ;i++)
    {
                    CardViewController* card = [storyBoard instantiateViewControllerWithIdentifier:@"HostConclusionCard"];
                    [self addChildViewController:card];
                    [self.view addSubview:card.view];
                    card.view.frame = CGRectMake(29, offset, 153, 262);
                    [card didMoveToParentViewController:self];
                    [card.viewLabel setText:[self.voters objectForKey:[self.votersIDs objectAtIndex:i]]];
        card.type = self.type;
        card.index = self.index;
        [card setImage:NO];
        offset+=30;
    }
    if(self.cardVotes==0)
    {
    
        CardViewController* card = [storyBoard instantiateViewControllerWithIdentifier:@"HostConclusionCard"];
        [self addChildViewController:card];
        [self.view addSubview:card.view];
        card.view.frame = CGRectMake(29, offset, 153, 262);
        [card didMoveToParentViewController:self];
        [card.viewLabel setText:@"-----"];
        card.type = self.type;
        card.index = self.index;
        [card setImage:YES];

    }
    [self.view bringSubviewToFront:self.cardCountLabel];

}


- (NSComparisonResult)compare:(HostConcludeCardViewController *)otherObject {
    if(self.type == otherObject.type){
        if(self.cardVotes == otherObject.cardVotes)
        {
            return [[NSNumber numberWithInteger:otherObject.index]compare:[NSNumber numberWithInteger:self.index]];
        }else{
         return [[NSNumber numberWithInteger:self.cardVotes]compare:[NSNumber numberWithInteger:otherObject.cardVotes]];
        }
    }else{
    return [[NSNumber numberWithInteger:otherObject.type]compare:[NSNumber numberWithInteger:self.type]];
    }
}

-(void)setPortaitMode
{
    [self reloadScreen];
}

-(void)setLandscapeMode
{
    [self reloadScreen];

}

@end
