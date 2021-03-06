//
//  StartViewController.h
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StartViewController : UIViewController
- (IBAction)startLogin:(id)sender;
- (IBAction)startRegistration:(id)sender;
- (IBAction)facebookButtonAction:(id)sender;
- (IBAction)twitterButtonAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *RegisterButton;
@property (weak, nonatomic) IBOutlet UIButton *LoginButton;

@end
