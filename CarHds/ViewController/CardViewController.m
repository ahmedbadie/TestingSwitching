//
//  CardViewController.m
//  CarHds
//
//  Created by Inova010 on 1/1/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "CardViewController.h"

@interface CardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *cardLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cardImageView;

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cardLabel.layer.borderWidth = 1.0f;
    [self.cardLabel.layer setCornerRadius:self.cardLabel.frame.size.width/2];
    self.cardLabel.clipsToBounds = YES;
    [self.cardLabel setText:[NSString stringWithFormat:@"%d",self.cardVotes]];
    [self.cardImageView setImage:self.cardImage];
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

@end
