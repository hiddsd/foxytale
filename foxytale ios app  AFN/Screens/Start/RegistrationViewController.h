//
//  RegistrationViewController.h
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACSClient.h"

@protocol RegisterDelegate;

@interface RegistrationViewController : UIViewController <UITextFieldDelegate,CCRequestDelegate>{
    id <RegisterDelegate> delegate;
}
@property (nonatomic, assign) id <RegisterDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
- (IBAction)emailBeginEditing:(id)sender;
- (IBAction)usernameBeginEditing:(id)sender;
- (IBAction)passwordBeginEditing:(id)sender;
- (IBAction)emailEndEditing:(id)sender;
- (IBAction)usernameEndEditing:(id)sender;
- (IBAction)passwordEndEditing:(id)sender;
- (IBAction)backgroundTap:(id)sender;
- (IBAction)register:(id)sender;

@end

@protocol RegisterDelegate
-(void)registerSucceeded;
-(void)registerFailed;
@end