//
//  SingleCardViewController.h
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SingleCardViewControllerDelegate <NSObject>

-(void) setIndex:(NSInteger) index;
-(void) changePageState:(NSInteger) pageIndex :(BOOL) pageOldValue;

@end
@interface SingleCardViewController : UIViewController<UIGestureRecognizerDelegate>

@property(nonatomic)NSInteger index;
@property (nonatomic) BOOL value;
@property (nonatomic) NSInteger type;

@property (nonatomic,strong) UITapGestureRecognizer* gesuterRecognizer;
@property (nonatomic,strong) UIViewController<SingleCardViewControllerDelegate>* delegate;
@property (nonatomic) BOOL shouldHandleTap;
@property (nonatomic) BOOL manualImage;
-(void) setImageWithAnimation:(BOOL) animated;
-(void) setImageForced:(UIImage*)image;
-(UIImage*) getImage;
-(void)setImageWithAnimation:(BOOL) animated ofType:(UIViewAnimationOptions) animationType;
-(void)setCardUserNames:(NSArray *)usersNames;

@end
