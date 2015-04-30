//
//  SingleCardViewController.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "SingleCardViewController.h"

@interface SingleCardViewController()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *namesTableview;
@property (strong, nonatomic)  NSArray *namesArray;

@end

@implementation SingleCardViewController

-(NSString *)getUserNameForIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        return  @"";
    }
    
    if(indexPath.row == self.namesArray.count + 1){
        return  @"";
    }
    NSInteger userIndex =(indexPath.row-1);
    NSDictionary * user = [self.namesArray objectAtIndex:userIndex];
    return [user objectForKey:@"username"];
    
    //    return [NSString stringWithFormat:@"index %ld",(long)userIndex];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * cellIdentifier = @"NameCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont fontWithName:@"LucidaGrande-Bold" size:21];
        cell.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        
    }
    
    cell.textLabel.text = [self getUserNameForIndexPath:indexPath];
    
    return  cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    if(self.namesArray == nil || self.namesArray.count == 0){
        return 0;
    }
    return self.namesArray.count + 2;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)setCardUserNames:(NSArray *)usersNames{
    self.namesArray = usersNames;
    [self.namesTableview reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(!self.manualImage)
        [self setImageWithAnimation:NO];
    
}

-(void)setImageWithAnimation:(BOOL)animated
{
    NSString* imageName = @"";
    if(self.type == 0)
        imageName = [NSString stringWithFormat:@"caRHds for odesk project.%ld%@.png",(long)(self.index+1),self.value? @"a":@"b"];
    if(self.type==1)
    {
        imageName= [NSString stringWithFormat:@"participantConclusion%ld.png",(long)(self.index+1)];
        animated= NO;
    }else if (self.type == 2)
    {
        imageName= [NSString stringWithFormat:@"meetingConclusion%ld.png",(long)(self.index+1)];
        animated= NO;
    }
    UIImage* image = [UIImage imageNamed:imageName];
    if(animated)
    {
        [UIView transitionWithView:self.view
                          duration:0.4
                           options:(self.value? UIViewAnimationOptionTransitionFlipFromLeft:UIViewAnimationOptionTransitionFlipFromRight)
                        animations:^{
                            //  Set the new image
                            //  Since its done in animation block, the change will be animated
                            
                            [self.imageView setImage: image];
                        } completion:^(BOOL finished) {
                            //  Do whatever when the animation is finished
                        }];
        
    }else{
        [self.imageView  setImage:image];
        //    [self.view addSubview:self.imageView];
        
    }
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.shouldHandleTap){
        self.gesuterRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap)];
        self.gesuterRecognizer.delegate = self;
        [self.view addGestureRecognizer:self.gesuterRecognizer];
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.delegate setIndex:self.index];
}

-(void)viewWillDisappear:(BOOL)animated
{
    if(self.shouldHandleTap){
        [self.gesuterRecognizer removeTarget:self action:@selector(handleTap)];
        self.gesuterRecognizer.delegate = self;
        [self.view removeGestureRecognizer:self.gesuterRecognizer];
    }
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
    [self setImageWithAnimation:YES];
    
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

-(UIImage *)getImage
{
    return [self.imageView image];
}
-(void)setImageForced:(UIImage *)image
{
    [self.imageView setImage:image];
}

-(void)setImageWithAnimation:(BOOL)animated ofType:(UIViewAnimationOptions)animationType
{
    NSString* imageName = @"";
    if(self.type == 0)
        imageName = [NSString stringWithFormat:@"caRHds for odesk project.%d%@.png",(self.index+1),self.value? @"a":@"b"];
    if(self.type==1)
    {
        imageName= [NSString stringWithFormat:@"participantConclusion%ld.png",(self.index+1)];
        animated= NO;
    }else if (self.type == 2)
    {
        imageName= [NSString stringWithFormat:@"meetingConclusion%ld.png",(self.index+1)];
        animated= NO;
    }
    UIImage* image = [UIImage imageNamed:imageName];
    if(animated)
    {
        [UIView transitionWithView:self.view
                          duration:0.4
                           options:animationType
                        animations:^{
                            //  Set the new image
                            //  Since its done in animation block, the change will be animated
                            
                            [self.imageView setImage: image];
                        } completion:^(BOOL finished) {
                            //  Do whatever when the animation is finished
                        }];
        
    }else{
        [self.imageView  setImage:image];
        //    [self.view addSubview:self.imageView];
        
    }
    
}
@end
