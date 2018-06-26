//
//  ParseCumunicator.m
//  StoryStrips
//
//  Created by Chris on 03.06.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ParseCumunicator.h"

@implementation ParseCumunicator

static ParseCumunicator *_sharedInstance = nil;

+(ParseCumunicator*)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

-(PFQuery*)queryForExplora:(NSNumber*)groupe searchoption:(NSNumber*)searchoption searchTerm:(NSString*)searchTerm pageIndex:(NSNumber*)pageIndex{
    
    PFQuery *query = nil;
    int offset = (int)[pageIndex integerValue] * 18;
    
    //All
    if([groupe integerValue] == 0){
        //User
        if([searchoption integerValue] == 1){
            // Query for User with Username
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"username" equalTo:searchTerm];
            
            // Query for Storys from User
            PFQuery *storysFromUserQuery = [PFQuery queryWithClassName:@"Story"];
            [storysFromUserQuery whereKey:@"creator" matchesQuery:userQuery];
            
            query = storysFromUserQuery;
            [query orderByDescending:@"createdAt"];
        }
        //hashtag
        else if([searchoption integerValue] == 2){
            // Query for Storys with hashtag
            PFQuery *storysWithHashtags = [PFQuery queryWithClassName:@"Story"];
            [storysWithHashtags whereKey:@"hashtags" hasPrefix:searchTerm];
            
            query = storysWithHashtags;
            [query orderByDescending:@"createdAt"];
        }
        //titel
        else if([searchoption integerValue] == 3){
            // Query for Storys with title
            PFQuery *titleQuery = [PFQuery queryWithClassName:@"Story"];
            [titleQuery whereKey:@"title" hasPrefix:searchTerm];
            
            query = titleQuery;
            [query orderByDescending:@"createdAt"];
        }
        //all --ordert by score--
        else{
            query = [PFQuery queryWithClassName:@"Story"];
            [query orderByDescending:@"score"];
        }
    }
    //Friends
    else if([groupe integerValue] == 1){
        //User
        if([searchoption integerValue] == 1){
            // Query for User with Username
            PFQuery *userQuery = [PFUser query];
            [userQuery whereKey:@"username" equalTo:searchTerm];
            
            // Query for friends with user
            PFQuery *friendsQuery = [PFQuery queryWithClassName:@"Activity"];
            [friendsQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [friendsQuery whereKey:@"type" equalTo:@"friend"];
            [friendsQuery whereKey:@"toUser" matchesQuery:userQuery];
            
            // Query for Storys from Friends
            PFQuery *storysFromFriendsQuery = [PFQuery queryWithClassName:@"Story"];
            [storysFromFriendsQuery whereKey:@"creator" matchesKey:@"toUser" inQuery:friendsQuery];
            
            query = storysFromFriendsQuery;
            [query orderByDescending:@"createdAt"];
        }
        //hashtag
        else if([searchoption integerValue] == 2){
            // Query for friends
            PFQuery *friendsQuery = [PFQuery queryWithClassName:@"Activity"];
            [friendsQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [friendsQuery whereKey:@"type" equalTo:@"friend"];

            // Query for Storys from Friends with Hashtag
            PFQuery *storysFromFriendsWithHashtagQuery = [PFQuery queryWithClassName:@"Story"];
            [storysFromFriendsWithHashtagQuery whereKey:@"creator" matchesKey:@"toUser" inQuery:friendsQuery];
            [storysFromFriendsWithHashtagQuery whereKey:@"hashtags" hasPrefix:searchTerm];
            
            query = storysFromFriendsWithHashtagQuery;
            [query orderByDescending:@"createdAt"];
        }
        //titel
        else if([searchoption integerValue] == 3){
            // Query for friends
            PFQuery *friendsQuery = [PFQuery queryWithClassName:@"Activity"];
            [friendsQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [friendsQuery whereKey:@"type" equalTo:@"friend"];
            
            // Query for Storys from Friends with Title
            PFQuery *storysFromFriendsWithTitleQuery = [PFQuery queryWithClassName:@"Story"];
            [storysFromFriendsWithTitleQuery whereKey:@"creator" matchesKey:@"toUser" inQuery:friendsQuery];
            [storysFromFriendsWithTitleQuery whereKey:@"title" hasPrefix:searchTerm];
            
            query = storysFromFriendsWithTitleQuery;
            [query orderByDescending:@"createdAt"];
        }
        //all
        else{
            // Query for friends
            PFQuery *friendsQuery = [PFQuery queryWithClassName:@"Activity"];
            [friendsQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
            [friendsQuery whereKey:@"type" equalTo:@"friend"];
            
            // Query for Storys from Friends
            PFQuery *storysFromFriendsQuery = [PFQuery queryWithClassName:@"Story"];
            [storysFromFriendsQuery whereKey:@"creator" matchesKey:@"toUser" inQuery:friendsQuery];
            
            query = storysFromFriendsQuery;
            [query orderByDescending:@"createdAt"];
        }
    }
    //Mine
    else if([groupe integerValue] == 2){
        //hashtag
        if([searchoption integerValue] == 2){
            // Query for my Storys with hashtag
            PFQuery *myStorysWithHashtagsQuery = [PFQuery queryWithClassName:@"Story"];
            [myStorysWithHashtagsQuery whereKey:@"hashtags" hasPrefix:searchTerm];
            [myStorysWithHashtagsQuery whereKey:@"creator" equalTo:[PFUser currentUser]];
            
            query = myStorysWithHashtagsQuery;
            [query orderByDescending:@"createdAt"];
        }
        //titel
        else if([searchoption integerValue] == 3){
            // Query for my Storys with title
            PFQuery *myTitleQuery = [PFQuery queryWithClassName:@"Story"];
            [myTitleQuery whereKey:@"title" hasPrefix:searchTerm];
            [myTitleQuery whereKey:@"creator" equalTo:[PFUser currentUser]];
            
            query = myTitleQuery;
            [query orderByDescending:@"createdAt"];
        }
        //all
        else{
            // Query for my Storys
            PFQuery *myStorysQuery = [PFQuery queryWithClassName:@"Story"];
            [myStorysQuery whereKey:@"creator" equalTo:[PFUser currentUser]];
            
            query = myStorysQuery;
            [query orderByDescending:@"createdAt"];
        }
    }
    
    [query setSkip: offset];
    [query setLimit: 19];
    return query;
}

-(PFQuery*)queryForStoryPage:(PFObject*)story{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"story" equalTo:story];
    [query includeKey:@"user"];
    [query orderByAscending:@"number"];
    return query;
}

-(PFQuery*)queryForUserContribute:(PFObject*)story{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"toStory" equalTo:story];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"contribute"];
    return query;
}

-(PFQuery*)queryForUserLike:(PFObject*)story{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"toStory" equalTo:story];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"type" equalTo:@"like"];
    return query;
}

-(PFQuery*)queryForFriends{
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Activity"];
    [friendQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [friendQuery whereKey:@"type" equalTo:@"friend"];
    [friendQuery selectKeys:@[@"toUser"]];
    [friendQuery includeKey:@"toUser"];
    return friendQuery;
}

-(PFQuery*)queryForUser:(NSString*)username{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:username];
    return query;
}

-(PFQuery*)searchUser:(NSString*)username{
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" hasPrefix:username];
    [query setLimit: 40];
    return query;
}

-(PFQuery*)queryForFriendRequest:(PFUser*)user{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [query whereKey:@"toUser" equalTo:user];
    [query whereKey:@"type" equalTo:@"friend"];
    return query;
}

-(PFQuery*)queryForNotifications:(NSNumber*)option{
    PFQuery *query = nil;
    // Notification to my Storys
    if([option integerValue] == 0){
        // Query for my Storys
        PFQuery *myStorysQuery = [PFQuery queryWithClassName:@"Story"];
        [myStorysQuery whereKey:@"creator" equalTo:[PFUser currentUser]];
        [myStorysQuery orderByDescending:@"updatedAt"];
        
        PFQuery *myStorysActivityQuery = [PFQuery queryWithClassName:@"Activity"];
        [myStorysActivityQuery whereKey:@"toStory" matchesQuery:myStorysQuery];
        [myStorysActivityQuery whereKey:@"type" containedIn:@[@"like",@"contribute"]];
        [myStorysActivityQuery whereKey:@"fromUser" notEqualTo:[PFUser currentUser]];
        [myStorysActivityQuery includeKey:@"toStory"];
        [myStorysActivityQuery includeKey:@"fromUser"];
        query = myStorysActivityQuery;
    }
    // Notification contributet Storys
    else if([option integerValue] == 1){
        // Query for my Storys
        PFQuery *myStorysQuery = [PFQuery queryWithClassName:@"Story"];
        [myStorysQuery whereKey:@"creator" equalTo:[PFUser currentUser]];
        [myStorysQuery orderByDescending:@"updatedAt"];
        
        // Query for my contributet Storys
        PFQuery *myContributetStorysQuery = [PFQuery queryWithClassName:@"Activity"];
        [myContributetStorysQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
        [myContributetStorysQuery whereKey:@"type" containedIn:@[@"like",@"contribute"]];
        [myContributetStorysQuery whereKey:@"toStory" doesNotMatchQuery:myStorysQuery];
        [myContributetStorysQuery orderByDescending:@"createdAt"];
        
        PFQuery *myContributetStorysActivityQuery = [PFQuery queryWithClassName:@"Activity"];
        [myContributetStorysActivityQuery whereKey:@"toStory" matchesKey:@"toStory" inQuery:myContributetStorysQuery];
        [myContributetStorysActivityQuery whereKey:@"type" containedIn:@[@"like",@"contribute"]];
        [myContributetStorysActivityQuery whereKey:@"fromUser" notEqualTo:[PFUser currentUser]];
        [myContributetStorysActivityQuery includeKey:@"toStory"];
        [myContributetStorysActivityQuery includeKey:@"fromUser"];
        query = myContributetStorysActivityQuery;
    }
    // Friend Requests
    else if([option integerValue] == 2){
        PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"Activity"];
        [friendRequestQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
        [friendRequestQuery whereKey:@"type" equalTo:@"friend"];
        [friendRequestQuery includeKey:@"fromUser"];
        query = friendRequestQuery;
    }
    [query orderByDescending:@"createdAt"];
    [query setLimit: 30];
    return query;
}

-(PFQuery*)queryForStoryFriend:(PFObject*)story{
    
    
    PFQuery *storyOwnerIsFriendQuery = [PFQuery queryWithClassName:@"Activity"];
    [storyOwnerIsFriendQuery whereKey:@"fromUser" equalTo:[story objectForKey:@"creator"]];
    [storyOwnerIsFriendQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];
    [storyOwnerIsFriendQuery whereKey:@"type" equalTo:@"friend"];
    return storyOwnerIsFriendQuery;
}

-(PFQuery*)queryForUsername:(NSString*)username{
    PFQuery *usernamequery = [PFUser query];
    [usernamequery whereKey:@"username" equalTo:username];
    return usernamequery;
}

-(PFQuery*)queryForFBID:(NSString*)fbId{
    PFQuery *fbIdquery = [PFUser query];
    [fbIdquery whereKey:@"fbId" equalTo:fbId];
    return fbIdquery;
}


@end
