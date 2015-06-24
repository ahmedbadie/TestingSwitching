//
//  UIButtonHelper.m
//  CarHds
//
//  Created by Inova PC 09 on 6/24/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "UIButtonHelper.h"

@implementation UIButtonHelper
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.titleLabel.frame;
    frame.size.height = self.bounds.size.height;
    frame.origin.y = self.titleEdgeInsets.top;
    self.titleLabel.frame = frame;
}
@end
