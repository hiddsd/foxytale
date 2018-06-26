//
//  facebookFriendsTableViewController.m
//  Foxytale
//
//  Created by Chris on 16.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "facebookFriendsTableViewController.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "FacebookFriendTableViewCell.h"
#import "ExploraScreenViewController.h"
#import "NoFacebookFriendsTableViewCell.h"
#import <Social/Social.h>


@interface facebookFriendsTableViewController (){
    NSArray *friendObjects;
    PFUser *userFromCell;
}

@end

@implementation facebookFriendsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadFFriends];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnTableView:)];
    [self.FFriendsTable addGestureRecognizer:tap];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"tellFacebookFriends" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"tellFacebookFriends"
                                               object:nil];
    [self.tableView registerNib:[UINib nibWithNibName:@"NoFacebookFriendsTableViewCell" bundle:nil] forCellReuseIdentifier:@"NoFFriendCell"];
    
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"tellFacebookFriends"]) {
        [self tellFriendsOnFacebook];
    }
}

-(void)loadFFriends{
    

    //DO IT!
    // Issue a Facebook Graph API request to get your user's friend list
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"Result:%@", result);
            // result will contain an array with your user's friends in the "data" key
            friendObjects = [result objectForKey:@"data"];
            [self.FFriendsTable reloadData];
        }
    }];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if(friendObjects.count == 0){
        return 1;
    }
    else return friendObjects.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger sectionsAmount = [tableView numberOfSections];
    NSInteger rowsAmount = [tableView numberOfRowsInSection:[indexPath section]];
    
    if((friendObjects == nil || [friendObjects count] == 0)){
        NoFacebookFriendsTableViewCell *nCell = [tableView dequeueReusableCellWithIdentifier:@"NoFFriendCell" forIndexPath:indexPath];
        [nCell setUpCell:0];
        return nCell;
    }
    else if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
        // This is the last cell in the table
        NoFacebookFriendsTableViewCell *nCell = [tableView dequeueReusableCellWithIdentifier:@"NoFFriendCell" forIndexPath:indexPath];
        [nCell setUpCell:1];
        return nCell;
    } else {
        FacebookFriendTableViewCell *nCell = [tableView dequeueReusableCellWithIdentifier:@"FFriendCell" forIndexPath:indexPath];
        nCell.friend = friendObjects[indexPath.row];
        [nCell setUpCell];
        return nCell;
    }
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    FacebookFriendTableViewCell *nCell = (FacebookFriendTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    userFromCell = nCell.friendUser;
    [self performSegueWithIdentifier:@"showFBFriendProfile" sender:self];
    NSLog(@"FriendUser:%@",userFromCell);
}

-(void) didTapOnTableView:(UIGestureRecognizer*) recognizer {
    CGPoint tapLocation = [recognizer locationInView:self.FFriendsTable];
    
    if(tapLocation.x > self.FFriendsTable.frame.size.width - 58){
        recognizer.cancelsTouchesInView = YES;
    }
    else{
        NSIndexPath *indexPath = [self.FFriendsTable indexPathForRowAtPoint:tapLocation];
        
        NSInteger sectionsAmount = [self.tableView numberOfSections];
        NSInteger rowsAmount = [self.tableView numberOfRowsInSection:[indexPath section]];
        
        if ([indexPath section] == sectionsAmount - 1 && [indexPath row] == rowsAmount - 1) {
            
            recognizer.cancelsTouchesInView = YES;
            
        }else {
            [self.FFriendsTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.FFriendsTable didSelectRowAtIndexPath:indexPath];
        }
    }

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([@"showFBFriendProfile" compare: segue.identifier]==NSOrderedSame) {
        
        ExploraScreenViewController *explora = (ExploraScreenViewController *)segue.destinationViewController;
        explora.searchTerm = [userFromCell username];
        explora.searchoption = [NSNumber numberWithInt:1];
        explora.searchBarText = [NSString stringWithFormat:@"@%@", [userFromCell username]];
    }
}

-(void)tellFriendsOnFacebook{
    
    
    //share on Facebook
    
    //IOS is hooked with Facebook
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        
        [controller setInitialText:NSLocalizedString(@"Check out Foxytale", nil)];
        [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id955868746"]];
        [controller setCompletionHandler:^(SLComposeViewControllerResult result)
         {
             if (result == SLComposeViewControllerResultCancelled)
             {
                 NSLog(@"The user cancelled.");
             }
             else if (result == SLComposeViewControllerResultDone)
             {
                 NSLog(@"The user posted to Facebook");
                 [self shareSuccessFacebook];
             }
         }];
        [self presentViewController:controller animated:YES completion:Nil];
    }else { //try true web or facebook app
    
    
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        [content setContentURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id955868746"]];
        [content setContentTitle:NSLocalizedString(@"Check out Foxytale", nil)];
        [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:self];
    
    }

}

-(void)shareSuccessFacebook {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                    message:NSLocalizedString(@"successfully postet on your wall",nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary*)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
    if([results objectForKey:@"postId"] != nil)[self shareSuccessFacebook];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}


@end
