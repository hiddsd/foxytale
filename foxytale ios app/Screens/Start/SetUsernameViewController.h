//
//  SetUsernameViewController.h
//  Foxytale
//
//  Created by Chris on 04.12.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetUsernameViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UIImageView *profilpic;
@property (nonatomic, assign) UIBackgroundTaskIdentifier profileImageUploadBackgroundTaskId;
- (IBAction)setFoxytaleUsername:(id)sender;
- (IBAction)usernameBeginnEditing:(id)sender;
- (IBAction)usernameEndEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end
