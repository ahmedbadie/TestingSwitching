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

    [self setImage:NO];
    
}

-(void) setImage:(BOOL)grayScale
{
    NSString* imageName = @"";
    switch (self.type) {
        case 0:
            imageName = @"participantConclusion";
            break;
        case 1:
            imageName = @"meetingConclusion";
            break;
        default:
            break;
    }
    
    imageName = [NSString stringWithFormat:@"%@%d%@.png",imageName,(self.index+1),grayScale? @"Gray":@"" ];
    UIImage* image = [UIImage imageNamed:imageName];
    [self.cardImageView setImage:image];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)setValueLabel:(NSInteger)value
{
    self.cardVotes = value;
    [self.cardLabel setText:[NSString stringWithFormat:@"%d",self.cardVotes]];
}

@end
