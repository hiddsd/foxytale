//
//  FacebookFriendTableViewCell.m
//  Foxytale
//
//  Created by Chris on 16.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "FacebookFriendTableViewCell.h"
#import "ParseCumunicator.h"


@implementation FacebookFriendTableViewCell

@synthesize facebookFriendAcceptBackgroundTaskId;
@synthesize friendUser;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpCell{
    self.addFriend.hidden = YES;
    
    //Facebook Name
    self.facebookName.text = [self.friend objectForKey:@"name"];
    
    //Get Parse Data
    ParseCumunicator *pc = [ParseCumunicator sharedInstance];
    PFQuery *query = [pc queryForFBID:[self.friend objectForKey:@"id"]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            friendUser = (PFUser*)object;
            
            //Username
            self.foxyName.text = [friendUser objectForKey:@"username"];
            
            //ProfilPic
            self.profielPic.layer.cornerRadius = self.profielPic.frame.size.width / 2;
            self.profielPic.clipsToBounds = YES;
            if([friendUser objectForKey:@"profilepic"] != nil){
                self.profielPic.file = [friendUser objectForKey:@"profilepic"];
                [self.profielPic loadInBackground];
            }
            else{
                self.profielPic.image = [UIImage imageNamed:@"profilepicph"];
            }
            
            //AddButton
            ParseCumunicator *pc = [ParseCumunicator sharedInstance];
            PFQuery *query = [pc queryForFriendRequest:friendUser];
            [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    // The count request succeeded. Log the count
                    if(count == 0){
                        self.addFriend.hidden = NO;
                        [self.addFriend setBackgroundColor:[UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1] forState:UIControlStateHighlighted];
                    }
                    else{
                        self.addFriend.hidden = YES;
                        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.addFriend.frame];
                        imgView.image = [UIImage imageNamed:@"checkmark.png"];
                        imgView.contentMode = UIViewContentModeCenter;
                        [self addSubview:imgView];
                    }
                } else {
                    // The request failed
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
            
            
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)addToFriends:(id)sender {
    self.addFriend.hidden = YES;
    //Create Activity
    PFObject *activity = [PFObject objectWithClassName:@"Activity"];
    [activity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [activity setObject:friendUser forKey:@"toUser"];
    [activity setObject:@"friend" forKey:@"type"];
    
    // Request a background execution task to allow us to finish uploading
    // the activity even if the app is sent to the background
    self.facebookFriendAcceptBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.facebookFriendAcceptBackgroundTaskId];
    }];
    
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ added you as a Friend",nil), [[PFUser currentUser]username]];
            [PFCloud callFunctionInBackground:@"sendPushToUser"
                               withParameters:@{@"recipientId": friendUser.objectId, @"message": message}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                // Push sent successfully
                                                NSLog(@"Push success!");
                                            }
                                        }];
            [[UIApplication sharedApplication] endBackgroundTask:self.facebookFriendAcceptBackgroundTaskId];
            
            //Update Friendslist
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Friend deleted"
                                                                object:self
                                                              userInfo:nil];
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.addFriend.frame];
            imgView.image = [UIImage imageNamed:@"checkmark.png"];
            imgView.contentMode = UIViewContentModeCenter;
            [self addSubview:imgView];
            
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.facebookFriendAcceptBackgroundTaskId];
            self.addFriend.hidden = NO;
        }
    }];
    
}



@end
