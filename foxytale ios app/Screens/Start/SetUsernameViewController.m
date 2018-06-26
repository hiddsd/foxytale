//
//  SetUsernameViewController.m
//  Foxytale
//
//  Created by Chris on 04.12.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "SetUsernameViewController.h"
#import "ParseCumunicator.h"
#import "UIAlertView+error.h"
#import "UIImage+Resize.h"
#import "UIImage+Utilities.h"
#import "CustomActionSheet.h"

@interface SetUsernameViewController (){
    NSData *profileImageData;
    PFFile *profileImageFile;
}

@end

@implementation SetUsernameViewController

@synthesize profileImageUploadBackgroundTaskId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
    
    self.profilpic.layer.cornerRadius = self.profilpic.frame.size.width / 2;
    self.profilpic.clipsToBounds = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.profilpic setUserInteractionEnabled:YES];
    [self.profilpic addGestureRecognizer:singleTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.profilpic.image = resizedImage;
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)setFoxytaleUsername:(id)sender {
    if (_username.text.length < 2) {
        [UIAlertView error:NSLocalizedString(@"Username must be at least 2 chars long.", nil)];
    }
    
    else {
        ParseCumunicator *pc = [ParseCumunicator sharedInstance];
        PFQuery *query = [pc queryForUsername:_username.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if(objects.count == 0){
                //Its Ok
                [[PFUser currentUser] setUsername:_username.text];
                [[PFUser currentUser] setObject:[NSNumber numberWithInt:0] forKey:@"reportCounter"];
                if(profileImageFile)[[PFUser currentUser] setObject:profileImageFile forKey:@"profilepic"];
                [[PFUser currentUser] saveInBackground];
                [self performSegueWithIdentifier:@"setUsername_success" sender:self];
            }
            else{
                //Username allready taken.
                [UIAlertView error:NSLocalizedString(@"Username allready taken", nil)];
            }
        }];
    }
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    //check if username and password is set and try login
    if (_username.text.length != 0) {
        [self setFoxytaleUsername:nil];
    }
    
    return YES;

    
}

- (IBAction)usernameBeginnEditing:(id)sender {
    self.username.placeholder = nil;
}

- (IBAction)usernameEndEditing:(id)sender {
    self.username.placeholder = NSLocalizedString(@"Username",nil);
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    if(textField == _username){
        return (newLength > 15) ? NO : YES;
    }
    else return YES;
}

@end
