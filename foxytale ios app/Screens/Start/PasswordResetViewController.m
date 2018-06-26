//
//  PasswordResetViewController.m
//  StoryStrips
//
//  Created by Chris on 01.12.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "PasswordResetViewController.h"
#import <Parse/Parse.h>

@interface PasswordResetViewController ()

@end

@implementation PasswordResetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

- (IBAction)resetPassword:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Reset Password", nil)]
                                                    message:[NSString stringWithFormat:NSLocalizedString(@"An email will be sent to your Email address that includes a password reset link", nil)] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    alert.tag = 1;
    [alert show];
}


- (void)alertView:(UIAlertView *)alertV didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [alertV cancelButtonIndex] && alertV.tag == 1)
    {
        [PFUser requestPasswordResetForEmailInBackground:self.emailTextField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)emailBeginnEditing:(id)sender {
    self.emailTextField.placeholder = nil;
}

- (IBAction)emailEndEditing:(id)sender {
    self.emailTextField.placeholder = @"E-Mail";
}
@end
