//
//  ProfileView.h
//  Foxytale
//
//  Created by Chris on 04.03.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "UIButton+BackgroundColor.h"

#define kprofilehight 60

@interface ProfileView : UIView

@property (weak, nonatomic) IBOutlet PFImageView *profilepic;
@property (weak, nonatomic) IBOutlet UILabel *storycount;
@property (weak, nonatomic) IBOutlet UILabel *contributecount;
@property (weak, nonatomic) IBOutlet UIButton_BackgroundColor *addasfriend;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property PFUser* user;
@property (nonatomic, assign) UIBackgroundTaskIdentifier friendAcceptBackgroundTaskId;


- (IBAction)addToFriends:(id)sender;

+(id)profileView;
-(id)initWithData:(PFUser*)data;
-(void)setProfilepicImage:(UIImage*)image;

@end
