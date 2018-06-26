//
//  PasswordResetViewController.h
//  StoryStrips
//
//  Created by Chris on 01.12.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordResetViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
- (IBAction)resetPassword:(id)sender;
- (IBAction)emailBeginnEditing:(id)sender;
- (IBAction)emailEndEditing:(id)sender;

@end
