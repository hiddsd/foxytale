//
//  FriendCell.h
//  StoryStrips
//
//  Created by Chris on 13.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "UIButton+BackgroundColor.h"

@interface FriendCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *friendProfilPic;
- (IBAction)deleteFriend:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *friendName;
@property (weak, nonatomic) PFObject *activityObject;
@property (weak, nonatomic) IBOutlet UIButton_BackgroundColor *deleteFriendButton;
@property PFUser *friend;
- (IBAction)goToFriendsPage:(id)sender;


-(void)setProfilePic;

@end
