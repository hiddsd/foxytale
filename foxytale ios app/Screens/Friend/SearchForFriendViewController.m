//
//  SearchForFriendViewController.m
//  Foxytale
//
//  Created by Chris on 21.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "SearchForFriendViewController.h"
#import "ParseCumunicator.h"
#import "SearchFriendTableViewCell.h"
#import "ExploraScreenViewController.h"

@interface SearchForFriendViewController (){
    NSArray *userList;
    PFUser *userFromCell;
}

@end

@implementation SearchForFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.UserSearchBar.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    self.progressLabel.text = @"";
    [self.UserSearchBar becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard {
    if([self.UserSearchBar isFirstResponder]){
        //self.searchBar.text = @"";
        [self.UserSearchBar resignFirstResponder];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if(searchBar.text.length >= 2){
        [self loadUsers];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = self.UserSearchBar.text;
    if([searchString length] >= 2){
        [self.UserSearchBar resignFirstResponder];
    }
}

- (void)loadUsers{
    ParseCumunicator *pc = [ParseCumunicator sharedInstance];
    PFQuery *query = [pc searchUser:self.UserSearchBar.text];
    self.progressLabel.text = NSLocalizedString(@"searching", nil);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            userList = objects;
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            [self.UserTableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        self.progressLabel.text = @"";
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchFriendTableViewCell *nCell = [tableView dequeueReusableCellWithIdentifier:@"FoxyFriendCell" forIndexPath:indexPath];
    nCell.friend = userList[indexPath.row];
    [nCell setUpFriendCell];
    return nCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return userList.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    SearchFriendTableViewCell *nCell = (SearchFriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    userFromCell = nCell.friend;
    [self performSegueWithIdentifier:@"showProfile" sender:self];
    NSLog(@"FriendUser:%@",userFromCell);
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([@"showProfile" compare: segue.identifier]==NSOrderedSame) {
        
        
        ExploraScreenViewController *explora = (ExploraScreenViewController *)segue.destinationViewController;
        explora.searchTerm = [userFromCell username];
        explora.searchoption = [NSNumber numberWithInt:1];
        explora.searchBarText = [NSString stringWithFormat:@"@%@", [userFromCell username]];
    }
}


@end
