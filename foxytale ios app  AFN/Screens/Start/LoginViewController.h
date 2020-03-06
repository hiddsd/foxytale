//
//  LoginViewController.h
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegistrationViewController.h"

@protocol LoginDelegate;

@interface LoginViewController : UIViewController <UITextFieldDelegate,RegisterDelegate,CCRequestDelegate>{
    id <LoginDelegate> delegate;
}
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)login:(id)sender;
- (IBAction)UsernameBeginEditing:(id)sender;
- (IBAction)PasswordBeginEditing:(id)sender;
- (IBAction)UsernameEndEditing:(id)sender;
- (IBAction)PasswordEndEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@end

@protocol LoginDelegate
-(void)loginSucceeded;
-(void)loginFailed;
@end