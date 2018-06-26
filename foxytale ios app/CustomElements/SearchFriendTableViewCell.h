//
//  SearchFriendTableViewCell.h
//  Foxytale
//
//  Created by Chris on 21.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface SearchFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet PFImageView *friendProfilPic;
@property (weak, nonatomic) IBOutlet UILabel *friendName;
@property PFUser *friend;
-(void)setUpFriendCell;



@end
