//
//  RegistrationViewController.m
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "RegistrationViewController.h"
#import "UIAlertView+error.h"
#import <Parse/Parse.h>
#import "UIImage+Resize.h"
#import "UIImage+Utilities.h"
#import "CustomActionSheet.h"


@interface RegistrationViewController (){
    NSData *profileImageData;
    PFFile *profileImageFile;
}

@end

@implementation RegistrationViewController

@synthesize profileImageUploadBackgroundTaskId;

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
    self.tapGestureRecogniza.cancelsTouchesInView = NO;
    
    self.profilepic.layer.cornerRadius = self.profilepic.frame.size.width / 2;
    self.profilepic.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.profilepic setUserInteractionEnabled:YES];
    [self.profilepic addGestureRecognizer:singleTap];
    
    
    TTTAttributedLabel *tttlabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, self.view.frame.size.height - 180, self.view.frame.size.width - 20, 50)];
    tttlabel.font = [UIFont systemFontOfSize:10];
    tttlabel.textColor = [UIColor lightGrayColor];
    tttlabel.lineBreakMode = NSLineBreakByWordWrapping;
    tttlabel.textAlignment = NSTextAlignmentJustified;
    tttlabel.numberOfLines = 0;
    tttlabel.delegate = self;
    tttlabel.userInteractionEnabled=YES;
    
    tttlabel.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
    //tttlabel.delegate = self; // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
    
    tttlabel.text = NSLocalizedString(@"By registering for Foxytale, you are indicating that you have read the User License Agreement and agree to the Privacy Policy",nil); // Repository URL will be automatically detected and linked
    
    NSRange range = [tttlabel.text rangeOfString:NSLocalizedString(@"User License Agreement",nil)];
    [tttlabel addLinkToURL:[NSURL URLWithString:@"http://www.foxytale.de/eula.html"] withRange:range];
    range = [tttlabel.text rangeOfString:NSLocalizedString(@"Privacy Policy",nil)];
    [tttlabel addLinkToURL:[NSURL URLWithString:@"http://www.foxytale.de/privacy.html"] withRange:range];
    [self.view addSubview:tttlabel];
}

-(void)tapDetected{
    NSArray* styles = @[@"cam",@"libary"];
    
    CustomActionSheet *popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"add a profile picture",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"take new picture",nil), NSLocalizedString(@"choose from library",nil), nil];
    [popupQuery showAlert];
}

-(void)modalAlertPressed:(CustomActionSheet *)alert withButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
        self.tabBarController.tabBar.hidden = YES;
        
    } else if (buttonIndex == 0) {
        
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.allowsEditing = YES;
            [self presentViewController:imagePicker animated:YES completion:nil];
            self.tabBarController.tabBar.hidden = YES;
        
    }
}

#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Resize the image to be square (what is shown in the preview)
    
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [[info valueForKey:UIImagePickerControllerOriginalImage]fixOrientation];
    cropRect = [originalImage convertCropRect:cropRect];
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                               bounds:CGSizeMake(100.0f, 100.0f)
                                                 interpolationQuality:kCGInterpolationDefault];
    self.profilepic.image = resizedImage;
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    profileImageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    
    [self shouldUploadImage];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)shouldUploadImage{
    // Create the PFFiles and store them in properties since we'll need them later
    profileImageFile = [PFFile fileWithData:profileImageData];
    
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.profileImageUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.profileImageUploadBackgroundTaskId];
    }];
    
    [profileImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[UIApplication sharedApplication] endBackgroundTask:self.profileImageUploadBackgroundTaskId];
    }];
}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
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
    
    if (_txtUsername.text.length != 0 && _txtPassword.text.length != 0 && _txtEmail.text.length !=0) {
        [self register:nil];
    }
    
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
    
    PFUser *user = [PFUser user];
    user.username = _txtUsername.text;
    user.password = _txtPassword.text;
    user.email = _txtEmail.text;
    [user setObject:[NSNumber numberWithInt:0] forKey:@"reportCounter"];
    if(profileImageFile)[user setObject:profileImageFile forKey:@"profilepic"];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            // Hooray! Let them use the app now.
            PFInstallation *currentInstallation=[PFInstallation currentInstallation];
            currentInstallation[@"currentUser"]=[PFUser currentUser];
            [currentInstallation saveInBackground];
            
            [self performSegueWithIdentifier:@"registration_success" sender:self];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            // Show the errorString somewhere and let the user try again.
            [UIAlertView error:errorString];
        }
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
