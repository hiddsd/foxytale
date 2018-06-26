//
//  FriendsScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 12.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "FriendsScreenViewController.h"
#import "API.h"
#import "FriendCell.h"
#import "ExploraScreenViewController.h"

@interface FriendsScreenViewController (){
    API *api;
}

@end

@implementation FriendsScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)getFriendsData
{
    api = [API sharedInstance];
    
    [api commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"friendlist",@"command",
                            nil]
              onCompletion:^(NSDictionary *json) {
                  [self showFriends:[json objectForKey:@"result"]];
              }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.addFriendNotificationLabel.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"Friend deleted"
                                               object:nil];
    [self getFriendsData];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    if(self.friendFromNotification){
        self.searchFriendTextField.text = self.friendFromNotification;
    }
    
}

-(void)dismissKeyboard {
    [self.searchFriendTextField resignFirstResponder];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"Friend deleted"]) {
        [self getFriendsData];
       [self.tabelView reloadData];
    }
}

-(void)showFriends:(NSMutableArray*)friendlist {
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    for (int i=0;i<[friendlist count];i++) {
        NSDictionary* friend = [friendlist objectAtIndex:i];
        [ary addObject:[friend objectForKey:@"username"]];
    }
    
    self.tblDictionary = [self fillingDictionary:ary];
    [self.tabelView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logout:(id)sender {
    //logout the user from the server, and also upon success destroy the local authorization
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"logout",@"command",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   
                                   //logged out from server
                                   [[API sharedInstance] logout];
                                   [self performSegueWithIdentifier:@"logout" sender:nil];
                               }];
    
}

- (IBAction)addFriend:(id)sender {
    //just call the "stream" command from the web API
    [api commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"addFriend",@"command",
                            self.searchFriendTextField.text, @"friendname",
                            nil]
              onCompletion:^(NSDictionary *json) {
                  if ([json objectForKey:@"error"]==nil) {
                      //success
                      
                    self.addFriendNotificationLabel.text = NSLocalizedString(@"friend added",nil);
                    [self getFriendsData];
                      
                      
                  } else {
                      //error
                      NSString* errorcode = [[NSString alloc] initWithString:[json objectForKey:@"error"]];
                      if([errorcode isEqualToString:@"0011"]){
                          self.addFriendNotificationLabel.text = NSLocalizedString(@"Sorry! There seems to be a problem connecting to our database. Please try again later.",nil);
                      }
                      else if([errorcode isEqualToString:@"0012"]){
                          self.addFriendNotificationLabel.text = NSLocalizedString(@"You are allready friends",nil);
                      }
                      else if([errorcode isEqualToString:@"0013"]){
                          self.addFriendNotificationLabel.text = [NSString stringWithFormat:NSLocalizedString(@"No user found with the name %@",nil), self.searchFriendTextField.text];
                      }
                  }
              }];

    
}

- (IBAction)goToFriendsPage:(id)sender {
    [self performSegueWithIdentifier:@"friendProvile" sender:sender];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header=[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
    [header setBackgroundColor:[UIColor darkGrayColor]];
    UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, 320, 20)];
    [header addSubview:lbl];
    [lbl setTextColor:[UIColor whiteColor]];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:[_keyArray objectAtIndex:section]];
    return header;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  [_keyArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *ary=[self.tblDictionary valueForKey:[_keyArray objectAtIndex:section]];
    return [ary count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendCell *friendCell=[tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    NSString *key=[_keyArray objectAtIndex:[indexPath section]];
    NSArray *array=(NSArray *)[self.tblDictionary valueForKey:key];
    NSString *cellTitle=[array objectAtIndex:[indexPath row]];
    [friendCell.friendName setTitle:cellTitle forState:UIControlStateNormal];
    [friendCell.friendName sizeToFit];
    return friendCell;
}

-(NSMutableDictionary *)fillingDictionary:(NSMutableArray *)ary
{    
    // This method has the real magic of this sample
    
    _keyArray=[[NSMutableArray alloc]init];
    [_keyArray removeAllObjects];
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    
    // First sort the array
    
    [ary sortUsingSelector:@selector(compare:)];
    
    
    // Get the first character of your string which will be your key
    
    for(NSString *str in ary)
    {
        char charval=[str characterAtIndex:0];
        NSString *charStr=[NSString stringWithFormat:@"%c",charval];
        if(![_keyArray containsObject:charStr])
        {
            NSMutableArray *charArray=[[NSMutableArray alloc]init];
            [charArray addObject:str];
            [_keyArray addObject:charStr];
            [dic setValue:charArray forKey:charStr];
        }
        else
        {
            NSMutableArray *prevArray=(NSMutableArray *)[dic valueForKey:charStr];
            [prevArray addObject:str];
            [dic setValue:prevArray forKey:charStr];
            
        }
        
    }
    return dic;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"friendProvile" compare: segue.identifier]==NSOrderedSame) {
        UIButton *button = (UIButton*)sender;
        UITabBarController *tabController = (UITabBarController*)segue.destinationViewController;
        tabController.selectedIndex = 0;
        UINavigationController *navController = (UINavigationController *)[tabController selectedViewController];
        ExploraScreenViewController *exploraController = (ExploraScreenViewController *)([navController viewControllers][0]);
        exploraController.option = [NSNumber numberWithInt:1];
        exploraController.segment.selectedSegmentIndex = 1;
        exploraController.searchoption = [NSNumber numberWithInt:1];
        exploraController.searchTerm = button.titleLabel.text;
        exploraController.searchBarText = [NSString stringWithFormat:@"@%@", button.titleLabel.text];
        exploraController.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"Search for User %@",nil), button.titleLabel.text];
    }
}

@end
