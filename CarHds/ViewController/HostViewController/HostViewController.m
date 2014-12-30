//
//  HostViewController.m
//  CarHds
//
//  Created by Inova010 on 12/30/14.
//  Copyright (c) 2014 Inova. All rights reserved.
//

#import "HostViewController.h"

@interface HostViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgs = [NSMutableArray array];
    self.handler = [[MeetingHandler alloc]init];
    self.handler.delegate = self;
    self.handler.chatDialog = self.chatDialog;
    self.handler.user = self.user;
    self.handler.chatRoom = self.chatRoom;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [QBChat instance].delegate = self.handler;
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.handler];
    
    [self.chatRoom leaveRoom];
    self.chatRoom = nil;

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    // Set keyboard notifications
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification object:nil];
    
    self.title = self.chatDialog.name;
    
    [self.handler connectToChatDialog:self.chatDialog];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



#pragma mark -Table Methods -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.msgs count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    QBChatAbstractMessage *message = self.msgs[indexPath.row];
    //
    [cell configureCellWithMessage:message];
    cell.user = self.user;
    return cell;
}




#
- (IBAction)sendMessage:(id)sender {
    
    if(self.messageTextField.text.length == 0){
        return;
    }
    
    [self.handler sendMessage:[self.messageTextField text] toChatRoom:self.chatRoom];
    // Reload table
    [self.tableView reloadData];
    if(self.msgs.count > 0){
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.msgs count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.messageTextField setText:nil];
}

#pragma mark
#pragma mark - Meeting Handler Delegate Methods -

-(void)didReciveMessages:(NSArray *)msgs
{
    [self.msgs addObjectsFromArray:msgs];
    [self.tableView reloadData];
    if([self.msgs count]>0)
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.msgs count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];

}

#pragma mark
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
