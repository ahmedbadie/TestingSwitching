//
//  AbstractNavigationController.m
//  CarHds
//
//  Created by Inova010 on 1/13/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "AbstractNavigationController.h"

@interface AbstractNavigationController ()

@end

@implementation AbstractNavigationController

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




-(NSUInteger)supportedInterfaceOrientations
{
    UIViewController* controller = self.topViewController;
    return [controller supportedInterfaceOrientations];

}
-(BOOL)shouldAutorotate
{
    UIViewController* controller = self.topViewController;
    return [controller shouldAutorotate];}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
 UIViewController* controller = self.topViewController;
    [controller didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}
@end
