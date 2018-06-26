//
//  OptionsTableViewController.m
//  Foxytale
//
//  Created by Chris on 08.12.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "UIAlertView+error.h"
#import <Parse/Parse.h>
//#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface OptionsTableViewController ()

@end

@implementation OptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int number;
    switch (section)
    {
        case 0:
            number = 2;
            break;
        case 1:
            number = 2;
            break;
        case 2:
            number = 1;
            break;
        default:
            number = 0;
            break;
    }
    return number;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Feedback", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"Change Password", nil);
            break;
        case 2:
            sectionName = NSLocalizedString(@"Logout", nil);
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"Feedback & Rating", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"Change Login Password", nil);
            break;
        case 2:
            sectionName = @"";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)passwordBeginnEditing:(id)sender {
    self.passwordTxtField.placeholder=NSLocalizedString(@"Password",nil);
}

- (IBAction)passwordEndEditing:(id)sender {
    self.passwordTxtField.placeholder=nil;
}

- (IBAction)changePassword:(id)sender {
    if (_passwordTxtField.text.length < 4 ){
        [UIAlertView error:NSLocalizedString(@"Password must be at least 5 chars long.",nil)];
        return;
    }
    self.passwordChangeButton.enabled = NO;
    [PFUser currentUser].password = _passwordTxtField.text;
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Password changed", nil)]
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Password was changed successfully", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"ok", nil)] otherButtonTitles:nil];
            [alert show];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            [UIAlertView error:errorString];
        }
        self.passwordChangeButton.enabled = YES;
    }];
}

- (IBAction)logout:(id)sender {
    PFInstallation *currentInstallation=[PFInstallation currentInstallation];
    [currentInstallation removeObjectForKey:@"currentUser"];
    [currentInstallation saveInBackground];
    
    //[[FBSession activeSession]closeAndClearTokenInformation];
    //[PFFacebookUtils unlinkUserInBackground:[PFUser currentUser]];
    
    [PFUser logOut];
    [self performSegueWithIdentifier:@"logout" sender:nil];
}

- (IBAction)giveFeedback:(id)sender {
    // Email Subject
    NSString *emailTitle = @"Feedback";
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"support@foxytale.de"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
}

- (IBAction)reviewApp:(id)sender {
    NSString *str = @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=955868746";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 7.1) {
        str = @"itms-apps://itunes.apple.com/app/id955868746";
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
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
@end
