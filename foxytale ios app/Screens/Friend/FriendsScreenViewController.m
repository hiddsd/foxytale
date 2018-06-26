//
//  FriendsScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 12.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "FriendsScreenViewController.h"
#import "FriendCell.h"
#import "ExploraScreenViewController.h"
#import <Parse/Parse.h>
#import "ParseCumunicator.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CustomActionSheet.h"

@interface FriendsScreenViewController (){
    NSMutableDictionary *activityToFriendDictionary;
    PFUser *userFromCell;
}

@end

@implementation FriendsScreenViewController

@synthesize friendAcceptBackgroundTaskId;

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
    ParseCumunicator *pc = [ParseCumunicator sharedInstance];
    PFQuery *query = [pc queryForFriends];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        [self showFriends:objects];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.addFriendNotificationLabel.text = @"";
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Friend deleted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"Friend deleted"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FriendCellUserSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"FriendCellUserSelected"
                                               object:nil];
    
    [self getFriendsData];
    
    self.tabelView.delaysContentTouches = NO;
    

    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"Friend deleted"]) {
        [self getFriendsData];
    }
    else if ([[notification name] isEqualToString:@"FriendCellUserSelected"]) {
        NSDictionary *dic = [notification userInfo];
        userFromCell = [dic valueForKey:@"user"];
        [self performSegueWithIdentifier:@"friendProvile" sender:self];
    }
}

-(void)showFriends:(NSArray*)friendlist {
    activityToFriendDictionary = [[NSMutableDictionary alloc] init];
    NSMutableArray *ary = [[NSMutableArray alloc] init];
    for (int i=0;i<[friendlist count];i++) {
        PFObject *activity = [friendlist objectAtIndex:i];
        PFObject *friend = [activity objectForKey:@"toUser"];
        [ary addObject:[friend objectForKey:@"username"]];
        [activityToFriendDictionary setObject:activity forKey:[friend objectForKey:@"username"]];
    }
    
    self.tblDictionary = [self fillingDictionary:ary];
    [self.tabelView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)addFriend:(PFUser*)user{
    
    //Create Activity
    PFObject *activity = [PFObject objectWithClassName:@"Activity"];
    [activity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [activity setObject:user forKey:@"toUser"];
    [activity setObject:@"friend" forKey:@"type"];
    
    // Request a background execution task to allow us to finish uploading
    // the activity even if the app is sent to the background
    self.friendAcceptBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.friendAcceptBackgroundTaskId];
    }];
    
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            self.addFriendNotificationLabel.text = NSLocalizedString(@"friend added",nil);
            [self getFriendsData];
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ added you as a Friend",nil), [[PFUser currentUser]username]];
            [PFCloud callFunctionInBackground:@"sendPushToUser"
                               withParameters:@{@"recipientId": user.objectId, @"message": message}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                // Push sent successfully
                                                NSLog(@"Push success!");
                                            }
                                        }];
            [[UIApplication sharedApplication] endBackgroundTask:self.friendAcceptBackgroundTaskId];
            
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.friendAcceptBackgroundTaskId];
        }
    }];
}

- (IBAction)shoudAddFriend:(id)sender {
    
    NSArray* styles = @[@"search",@"facebook",@"whatsapp",@"email",@"sms"];
    
    CustomActionSheet *popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"Add Friends",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"by username",nil),@"facebook",@"whatsapp",@"email",@"sms", nil];
    [popupQuery showAlert];
    
}

-(void)modalAlertPressed:(CustomActionSheet *)alert withButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld", (long)buttonIndex);
    if(buttonIndex == 0) {
        //search username
        [self performSegueWithIdentifier:@"searchForFriend" sender:self];
        
    } else if (buttonIndex == 1) {
        //add facebook
        if(![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) { //check if user is allready linked to facebook profile
            NSArray *permissions = @[@"user_friends"];
            [PFFacebookUtils linkUserInBackground:[PFUser currentUser] withReadPermissions:permissions block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"Woohoo, user logged in with Facebook!");
                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
                    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (!error) {
                            // Store the current user's Facebook ID on the user
                            [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                                     forKey:@"fbId"];
                            [[PFUser currentUser] saveInBackground];
                        }
                    }];
                }
                else if (error) {
                    NSString *errorMessage = nil;
                    NSLog(@"Uh oh. An error occurred: %@", error);
                    errorMessage = [error localizedDescription];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                    message:errorMessage
                                                                   delegate:nil
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                }
            }];
        }else if (![[FBSDKAccessToken currentAccessToken] hasGranted:@"user_friends"]) {
            NSArray *permissions = [[NSArray alloc] initWithObjects: @"user_friends", nil];
            
            FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
            [loginManager logInWithReadPermissions:permissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    if (!error) {
                        NSLog(@"Reauthorized with publish permissions.");
                    }
                    else {
                        NSLog(@"Sadly not...");
                    }
                }];
        }
            
        [self performSegueWithIdentifier:@"showFacebookFriends" sender:self];
    } else if (buttonIndex == 2) {
        //WhatsApp
        NSString *message= NSLocalizedString(([NSString stringWithFormat:@"I am as %@ on Foxytale. Install the App, to follow my tales and contribute to them. https://itunes.apple.com/app/id955868746", PFUser.currentUser.username ]),nil);
        NSString *urlMessage = [NSString stringWithFormat:@"whatsapp://send?text=%@",message];
        NSURL * whatsappURL = [NSURL URLWithString:[urlMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"Message:%@",whatsappURL);
        
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }
    } else if (buttonIndex == 3) {
        //Email
        // Email Subject
        NSString *emailTitle = NSLocalizedString(@"Join Foxytale too!",nil);
        // Email Content
        NSString *messageBody = NSLocalizedString(([NSString stringWithFormat:@"I am as %@ on Foxytale. Install the App, to follow my tales and contribute to them. https://itunes.apple.com/app/id955868746", PFUser.currentUser.username ]),nil);
        // To address
        NSArray *toRecipents = [NSArray arrayWithObject:@""];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        [mc setToRecipients:toRecipents];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
        
    } else if (buttonIndex == 4){
        //SMS
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        NSArray *recipents = @[@""];
        NSString *message = NSLocalizedString(([NSString stringWithFormat:@"I am as %@ on Foxytale. Install the App, to follow my tales and contribute to them. https://itunes.apple.com/app/id955868746", PFUser.currentUser.username ]),nil);
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setRecipients:recipents];
        [messageController setBody:message];
        
        // Present message view controller on screen
        [self presentViewController:messageController animated:YES completion:nil];
        
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
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
    friendCell.activityObject = [activityToFriendDictionary objectForKey:cellTitle];
    [friendCell setProfilePic];
    
    for (id obj in friendCell.subviews)
    {
        if ([NSStringFromClass([obj class]) isEqualToString:@"UITableViewCellScrollView"])
        {
            UIScrollView *scroll = (UIScrollView *) obj;
            scroll.delaysContentTouches = NO;
            break;
        }
    }
    
    return friendCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
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
        ExploraScreenViewController *exploraController = (ExploraScreenViewController *)segue.destinationViewController;
        exploraController.option = [NSNumber numberWithInt:1];
        exploraController.segment.selectedSegmentIndex = 1;
        exploraController.searchoption = [NSNumber numberWithInt:1];
        exploraController.searchTerm = [userFromCell username];
        exploraController.searchBarText = [NSString stringWithFormat:@"@%@", [userFromCell username]];
        exploraController.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"Search for User %@",nil), [userFromCell username]];
    }
}

@end
