//
//  OptionsTableViewController.h
//  Foxytale
//
//  Created by Chris on 08.12.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface OptionsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTxtField;

- (IBAction)passwordBeginnEditing:(id)sender;
- (IBAction)passwordEndEditing:(id)sender;
- (IBAction)changePassword:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)giveFeedback:(id)sender;
- (IBAction)reviewApp:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *passwordChangeButton;

@end
