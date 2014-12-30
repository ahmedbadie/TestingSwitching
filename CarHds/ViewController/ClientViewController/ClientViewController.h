//
//  ClientViewController.h
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "AbstractViewController.h"
#import "ChatMessageTableViewCell.h"
@interface ClientViewController : AbstractViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (nonatomic,strong) NSMutableArray* messages;
@property (nonatomic,strong) QBChatRoom* chatRoom;

@end
