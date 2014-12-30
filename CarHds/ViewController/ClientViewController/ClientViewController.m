//
//  ClientViewController.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "ClientViewController.h"

@interface ClientViewController ()

@end

@implementation ClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.messages = [NSMutableArray array];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.messages = [NSMutableArray array];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.handler = [[MeetingHandler alloc]init];
    self.handler.delegate = self;
    self.handler.chatDialog =self.chatDialog;
    self.handler.chatRoom = self.chatRoom;
    self.handler.user = self.user;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
        
            self.title = self.chatDialog.name;
    [self.handler connectToChatDialog:self.chatDialog];
   

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.handler];
    
    [self.chatRoom leaveRoom];
    self.chatRoom = nil;
}

-(BOOL)hidesBottomBarWhenPushed
{
    return YES;
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

- (IBAction)sendMessage:(id)sender {
    
    if(self.messageTextField.text.length == 0){
        return;
    }
    
    // create a message
    [self.handler sendMessage:[self.messageTextField text] toChatRoom:self.chatRoom];
    // Reload table
    [self.tableView reloadData];
    if(self.messages.count > 0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.messageTextField setText:nil];

}



#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier2";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    QBChatAbstractMessage *message = self.messages[indexPath.row];
    //
    [cell configureCellWithMessage:message];
    cell.user = self.user;
    return cell;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    QBChatAbstractMessage *chatMessage = [self.messages objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage];
    return cellHeight;
}


#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}




#pragma mark
#pragma mark - Meeting Handler Delegate Methods -

-(void)didReciveMessages:(NSArray *)msgs
{
    [self.messages addObjectsFromArray:msgs];
    [self.tableView reloadData];
    if([self.messages count]>0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}


@end
