//
//  NoFacebookFriendsTableViewCell.m
//  Foxytale
//
//  Created by Chris on 03.08.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "NoFacebookFriendsTableViewCell.h"


@implementation NoFacebookFriendsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setUpCell:(int)option{
    if(option == 0) self.descriptionLabel.text = NSLocalizedString(@"No Facebook friend found who uses Foxytale", nil);
    else self.descriptionLabel.text = @"";
    self.tellFriendsButton.titleLabel.text = NSLocalizedString(@"Tell your friends you're here", nil);
}

- (IBAction)tellFriends:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tellFacebookFriends"
                                                        object:self
                                                      userInfo:nil];
    
}
@end
