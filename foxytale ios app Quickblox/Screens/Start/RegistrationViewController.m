//
//  RegistrationViewController.m
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "RegistrationViewController.h"
#import "UIAlertView+error.h"
#import "SSUUserCache.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController

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

- (IBAction)emailBeginEditing:(id)sender {
    self.txtEmail.placeholder=nil;
}

- (IBAction)usernameBeginEditing:(id)sender {
    self.txtUsername.placeholder=nil;
}

- (IBAction)passwordBeginEditing:(id)sender {
    self.txtPassword.placeholder=nil;
}

- (IBAction)emailEndEditing:(id)sender {
    self.txtEmail.placeholder=NSLocalizedString(@"E-Mail",nil);
}

- (IBAction)usernameEndEditing:(id)sender {
    self.txtUsername.placeholder=NSLocalizedString(@"Username",nil);
}

- (IBAction)passwordEndEditing:(id)sender {
    self.txtPassword.placeholder=NSLocalizedString(@"Password",nil);
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)register:(id)sender {
    //form fields validation
    if (_txtUsername.text.length < 2 ){
        [UIAlertView error:NSLocalizedString(@"Username must be at least 2 chars long.",nil)];
        return;
    }
    if (_txtPassword.text.length < 7 ){
        [UIAlertView error:NSLocalizedString(@"Password must be at least 5 chars long.",nil)];
        return;
    }
    if(![self validateEmail:[_txtEmail text]]) {
        [UIAlertView error:NSLocalizedString(@"Please enter a valid email address.",nil)];
        return;
    }
    
    // Create QuickBlox User entity
    QBUUser *user = [QBUUser user];
	user.password = _txtPassword.text;
    user.login = _txtUsername.text;
    user.email = _txtEmail.text;

    // create User
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        [[SSUUserCache instance] saveUser:user];
        [self performSegueWithIdentifier:@"registration_success" sender:self];
    } errorBlock:^(QBResponse *response) {
        NSString *errorString = [response.error description];
        // Show the errorString somewhere and let the user try again.
        [UIAlertView error:errorString];
    }];
    
    
}

- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(textField == _txtUsername){
        return (newLength > 15) ? NO : YES;
    }
    else if(textField == _txtEmail){
        return (newLength > 254) ? NO : YES;
    }
    else if(textField == _txtPassword){
        return (newLength > 45) ? NO : YES;
    }
    else return YES;
}

@end
