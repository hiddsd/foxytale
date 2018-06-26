//
//  SearchFriendTableViewCell.m
//  Foxytale
//
//  Created by Chris on 21.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "SearchFriendTableViewCell.h"

@implementation SearchFriendTableViewCell

@synthesize friend;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpFriendCell{
    //Username
    self.friendName.text = [friend objectForKey:@"username"];    
    
    //Profile Pic
    self.friendProfilPic.layer.cornerRadius = self.friendProfilPic.frame.size.width / 2;
    self.friendProfilPic.clipsToBounds = YES;
    if([friend objectForKey:@"profilepic"] != nil){
        self.friendProfilPic.file = [friend objectForKey:@"profilepic"];
        [self.friendProfilPic loadInBackground];
    }
    else{
        self.friendProfilPic.image = [UIImage imageNamed:@"profilepicph"];
    }
}


@end
