//
//  LoginViewController.h
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)login:(id)sender;
- (IBAction)UsernameBeginEditing:(id)sender;
- (IBAction)PasswordBeginEditing:(id)sender;
- (IBAction)UsernameEndEditing:(id)sender;
- (IBAction)PasswordEndEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;


@end
