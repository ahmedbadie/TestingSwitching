//
//  ChatMessageTableViewCell.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/19/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Quickblox/Quickblox.h>
@interface ChatMessageTableViewCell : UITableViewCell

@property (nonatomic, strong) UITextView  *messageTextView;
@property (nonatomic, strong) UILabel     *dateLabel;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic,strong) QBUUser* user;
+ (CGFloat)heightForCellWithMessage:(QBChatAbstractMessage *)message;
- (void)configureCellWithMessage:(QBChatAbstractMessage *)message;

@end
