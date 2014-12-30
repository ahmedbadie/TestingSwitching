//
//  SingleCardViewController.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "SingleCardViewController.h"

@interface SingleCardViewController ()
@property (nonatomic,strong) UIImageView* imageView;
@end

@implementation SingleCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setImage];
    
    // Do any additional setup after loading the view.
}

-(void) setImage
{
    if(self.imageView)
    {
        [self.imageView removeFromSuperview];
    }
    NSString* imageName = [NSString stringWithFormat:@"caRHds for odesk project.%d%@.png",(self.index+1),self.value? @"a":@"b"];
    UIImage* image = [UIImage imageNamed:imageName];
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    [self.imageView  setImage:[self imageRotatedByDegrees:image deg:90]];
    [self.view addSubview:self.imageView];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.gesuterRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
    self.gesuterRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.gesuterRecognizer];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.delegate setIndex:self.index];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.gesuterRecognizer removeTarget:self action:@selector(handleTap)];
    self.gesuterRecognizer.delegate = self;
    [self.view removeGestureRecognizer:self.gesuterRecognizer];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) handleTap
{
    NSLog(@"Tap");
    
    [self.delegate changePageState:self.index :self.value];
    self.value = !self.value;
    [self setImage];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
    }
@end
