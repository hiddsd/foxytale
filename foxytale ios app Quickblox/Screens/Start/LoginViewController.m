//
//  LoginViewController.m
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "LoginViewController.h"
#import "UIAlertView+error.h"
#import "SSUUserCache.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

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

- (IBAction)login:(id)sender {
    // Authenticate user
    [QBRequest logInWithUserLogin:_txtUsername.text password:_txtPassword.text
                     successBlock:^(QBResponse *response, QBUUser *user) {
                         [[SSUUserCache instance] saveUser:user];
                         [self performSegueWithIdentifier:@"login_success" sender:self];
                     } errorBlock:^(QBResponse *response) {
                         NSString *errorString = [response.error description];
                         // Show the errorString somewhere and let the user try again.
                         [UIAlertView error:errorString];
                     }];

}

- (IBAction)UsernameBeginEditing:(id)sender {
    self.txtUsername.placeholder = nil;
}

- (IBAction)PasswordBeginEditing:(id)sender {
    self.txtPassword.placeholder = nil;
}

- (IBAction)UsernameEndEditing:(id)sender {
    self.txtUsername.placeholder = NSLocalizedString(@"Username",nil);
}

- (IBAction)PasswordEndEditing:(id)sender {
     self.txtPassword.placeholder = NSLocalizedString(@"Password",nil);
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(textField == _txtUsername){
        return (newLength > 15) ? NO : YES;
    }
    else if(textField == _txtPassword){
        return (newLength > 45) ? NO : YES;
    }
    else return YES;
}

@end
