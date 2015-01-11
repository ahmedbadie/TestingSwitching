//
//  HostConcludeCardViewController.h
//  CarHds
//
//  Created by Inova010 on 1/11/15.
//  Copyright (c) 2015 Inova. All rights reserved.
//

#import "AbstractViewController.h"
#import "CardViewController.h"
@interface HostConcludeCardViewController : AbstractViewController
@property (weak, nonatomic) IBOutlet UILabel *cardCountLabel;

@property(nonatomic) NSUInteger type;
@property(nonatomic) NSUInteger index;
@property(nonatomic,strong) NSMutableArray* votersIDs;
@property (nonatomic,strong) NSMutableDictionary* voters;
@property (nonatomic) NSInteger  cardVotes;
-(void) addVote:(NSString*) userName : (NSUInteger) userId;
-(void) removeVoter:(NSUInteger) userId;
-(void) reloadScreen;
@end
