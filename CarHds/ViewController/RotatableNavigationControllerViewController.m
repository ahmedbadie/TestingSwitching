//
//  RotatableNavigationControllerViewController.m
//  CarHds
//
//  Created by Inova010 on 1/13/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "RotatableNavigationControllerViewController.h"

@interface RotatableNavigationControllerViewController ()

@end

@implementation RotatableNavigationControllerViewController

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
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
-(BOOL)shouldAutorotate
{
    return YES;
}

@end
