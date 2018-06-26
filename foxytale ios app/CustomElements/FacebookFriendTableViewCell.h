//
//  FacebookFriendTableViewCell.h
//  Foxytale
//
//  Created by Chris on 16.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "UIButton+BackgroundColor.h"

@interface FacebookFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *foxyName;
@property (weak, nonatomic) IBOutlet UILabel *facebookName;
@property (weak, nonatomic) IBOutlet UIButton_BackgroundColor *addFriend;
@property (weak, nonatomic) IBOutlet PFImageView *profielPic;
@property NSDictionary *friend;
@property PFUser *friendUser;

@property (nonatomic, assign) UIBackgroundTaskIdentifier facebookFriendAcceptBackgroundTaskId;

-(void)setUpCell;

- (IBAction)addToFriends:(id)sender;


@end
