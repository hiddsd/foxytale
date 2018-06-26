//
//  StartViewController.m
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "StartViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>


@interface StartViewController ()

@end

@implementation StartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startLogin:(id)sender {
    [self performSegueWithIdentifier:@"start_login" sender: self];
}

- (IBAction)startRegistration:(id)sender {
    [self performSegueWithIdentifier:@"start_registration" sender: self];
}

- (IBAction)facebookButtonAction:(id)sender {
    [PFFacebookUtils logInInBackgroundWithReadPermissions:nil block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else {
            if([[PFUser currentUser] objectForKey:@"fbId"] == nil){
                //Get FB id
                NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
                [parameters setValue:@"id" forKey:@"fields"];
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        NSLog(@"user:%@", result);
                        // Store the current user's Facebook ID on the user
                        [[PFUser currentUser] setObject:[result objectForKey:@"id"]
                                                 forKey:@"fbId"];
                        [[PFUser currentUser] saveInBackground];
                    }
                }];
            }
            // Do stuff after successful login.
            PFInstallation *currentInstallation=[PFInstallation currentInstallation];
            currentInstallation[@"currentUser"]=[PFUser currentUser];
            [currentInstallation saveInBackground];
            if (user.isNew) {
                NSLog(@"User with facebook signed up and logged in!");
                [self performSegueWithIdentifier:@"set_username" sender:self];
            } else {
                NSLog(@"User with facebook logged in!");
                [self performSegueWithIdentifier:@"externallogin_success" sender:self];
            }
        }
    }];
}

- (IBAction)twitterButtonAction:(id)sender {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Twitter login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        } else {
            // Do stuff after successful login.
            PFInstallation *currentInstallation=[PFInstallation currentInstallation];
            currentInstallation[@"currentUser"]=[PFUser currentUser];
            [currentInstallation saveInBackground];
            if (user.isNew) {
                NSLog(@"User with Twitter signed up and logged in!");
                [self performSegueWithIdentifier:@"set_username" sender:self];
            } else {
                NSLog(@"User with Twitter logged in!");
                [self performSegueWithIdentifier:@"externallogin_success" sender:self];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

@end
