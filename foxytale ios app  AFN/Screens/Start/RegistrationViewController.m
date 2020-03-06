//
//  RegistrationViewController.m
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "RegistrationViewController.h"
#import "UIAlertView+error.h"

@interface RegistrationViewController ()


@end

@implementation RegistrationViewController
@synthesize delegate;
CCRequest *pendingRequest;

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
    if (_txtPassword.text.length < 4 ){
        [UIAlertView error:NSLocalizedString(@"Password must be at least 5 chars long.",nil)];
        return;
    }
    if(![self validateEmail:[_txtEmail text]]) {
        [UIAlertView error:NSLocalizedString(@"Please enter a valid email address.",nil)];
        return;
    }
    
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [paramDict setObject:_txtUsername.text forKey:@"username"];
    [paramDict setObject:_txtPassword.text forKey:@"password"];
    [paramDict setObject:_txtEmail.text forKey:@"email"];
    
    // make a https call
    pendingRequest = [[CCRequest alloc] initHttpsWithDelegate:self httpMethod:@"POST" baseUrl:@"users/create.json" paramDict:paramDict];
    [pendingRequest startAsynchronous];
    
}

#pragma mark -
#pragma mark CCRequest Delegate methods
/* Sucessful registration */
-(void)ccrequest:(CCRequest *)request didSucceed:(CCResponse *)response
{
    if ([request isEqual:pendingRequest]) {
        [self performSegueWithIdentifier:@"registration_success" sender:self];
    }
}


-(void)ccrequest:(CCRequest *)request didFailWithError:(NSError *)error
{
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"Register Failed!"
						  message:[error localizedDescription]
						  delegate:self
						  cancelButtonTitle:@"Ok"
						  otherButtonTitles:nil];
	[alert show];    
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
