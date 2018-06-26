//
//  FriendCell.m
//  StoryStrips
//
//  Created by Chris on 13.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "FriendCell.h"
#import <Parse/Parse.h>
#import "ParseCumunicator.h"

@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteFriend:(id)sender {
    NSLog(@"OBJECT: %@", self.activityObject);
    [self.activityObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Friend deleted"
                                                            object:self
                                                          userInfo:nil];
        }
    }];
}

- (IBAction)goToFriendsPage:(id)sender {
    [self tapUser];
}

-(void)setProfilePic{
    //Button
    [self.deleteFriendButton setBackgroundColor:[UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1] forState:UIControlStateHighlighted];
    //Profile Pic
    self.friend = [self.activityObject objectForKey:@"toUser"];
    self.friendProfilPic.layer.cornerRadius = self.friendProfilPic.frame.size.width / 2;
    self.friendProfilPic.clipsToBounds = YES;
    if([self.friend objectForKey:@"profilepic"] != nil){
        self.friendProfilPic.file = [self.friend objectForKey:@"profilepic"];
        [self.friendProfilPic loadInBackground];
    }
    else{
        self.friendProfilPic.image = [UIImage imageNamed:@"profilepicph"];
    }
    //gesture recognizer
    if([self.friendProfilPic gestureRecognizers] == nil){
        
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser)];
        userTap.numberOfTapsRequired = 1;
        [self.friendProfilPic setUserInteractionEnabled:YES];
        [self.friendProfilPic addGestureRecognizer:userTap];
    }
}

-(void)tapUser{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.friend forKey:@"user"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FriendCellUserSelected"
                                                        object:self
                                                      userInfo:dict];
}

@end
