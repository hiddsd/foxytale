//
//  ParseCumunicator.h
//  StoryStrips
//
//  Created by Chris on 03.06.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface ParseCumunicator : NSObject

+(ParseCumunicator*)sharedInstance;

-(PFQuery*)queryForExplora:(NSNumber*)groupe searchoption:(NSNumber*)searchoption searchTerm:(NSString*)searchTerm pageIndex:(NSNumber*)pageIndex;
-(PFQuery*)queryForStoryPage:(PFObject*)story;
-(PFQuery*)queryForUserContribute:(PFObject*)story;
-(PFQuery*)queryForUserLike:(PFObject*)story;
-(PFQuery*)queryForFriends;
-(PFQuery*)queryForUser:(NSString*)username;
-(PFQuery*)queryForFriendRequest:(PFUser*)user;
-(PFQuery*)queryForNotifications:(NSNumber*)option;
-(PFQuery*)queryForStoryFriend:(PFObject*)story;
-(PFQuery*)queryForUsername:(NSString*)username;
-(PFQuery*)queryForFBID:(NSString*)fbId;
-(PFQuery*)searchUser:(NSString*)username;
@end
