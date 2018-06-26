//
//  LoadingScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 03.04.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "LoadingScreenViewController.h"
#import <Parse/Parse.h>
//#import "myParseLoginViewController.h"
//#import "myParseSignUpViewController.h"

@interface LoadingScreenViewController ()

@end

@implementation LoadingScreenViewController

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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([PFUser currentUser]) {
        // do stuff with the user
        [self performSegueWithIdentifier:@"signedin" sender:self];
    } else {
        
        // show the signup or login screen
        
        [self performSegueWithIdentifier:@"signin" sender:self];
    }
    
    /*
    if (![PFUser currentUser]) { // No user logged in
        myParseLoginViewController *logInController = [[myParseLoginViewController alloc] init];
        logInController.delegate = self;
        logInController.fields = (PFLogInFieldsUsernameAndPassword
                                  | PFLogInFieldsLogInButton
                                  | PFLogInFieldsSignUpButton
                                  | PFLogInFieldsPasswordForgotten
                                  | PFLogInFieldsFacebook
                                  | PFLogInFieldsTwitter);
        logInController.facebookPermissions = @[ @"email" ];
        logInController.signUpController = [[myParseSignUpViewController alloc] init];
        [self presentViewController:logInController animated:YES completion:nil];        
    }
    else{
        [self performSegueWithIdentifier:@"signedin" sender:self];
    }*/
}

/*
- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"signedin" sender:self];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    
}*/

@end
