//
//  NoFacebookFriendsTableViewCell.h
//  Foxytale
//
//  Created by Chris on 03.08.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NoFacebookFriendsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *tellFriendsButton;
- (IBAction)tellFriends:(id)sender;

-(void)setUpCell:(int)option;

@end
