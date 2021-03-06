//
//  CardViewController.h
//  CarHds
//
//  Created by Inova010 on 1/1/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardViewController : UIViewController
@property (nonatomic) NSInteger cardVotes;
@property (nonatomic,strong) UIImage* cardImage;
@property (nonatomic) NSInteger type;
@property (nonatomic) NSInteger index;
@property (weak, nonatomic) IBOutlet UILabel *viewLabel;
-(void) setValueLabel:(NSInteger) value;
-(void) setImage:(BOOL) grayScale;

@end
