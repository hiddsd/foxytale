//
//  QuickbloxCumunicator.m
//  StoryStrips
//
//  Created by Chris on 22.09.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "QuickbloxCumunicator.h"
#import "SSUUserCache.h"


@implementation QuickbloxCumunicator

const int MAX_RESULTS = 18;
const int MAX_ACTIVITYS = 30;

static QuickbloxCumunicator *_sharedInstance = nil;

+(QuickbloxCumunicator*)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

-(void)queryForExplora:(NSNumber*)groupe searchoption:(NSNumber*)searchoption searchTerm:(NSString*)searchTerm pageIndex:(NSNumber*)pageIndex onCompletion:(ResponseBlock)completionBlock{
    
    int offset = (int)[pageIndex integerValue] * MAX_RESULTS;
    
    //ALL
    if([groupe integerValue] == 0){
        //User
        if([searchoption integerValue] == 1){
            //Quey for User with Username
            [QBRequest userWithLogin:searchTerm successBlock:^(QBResponse *response, QBUUser *user) {
                // Query for Storys from User
                NSMutableDictionary *storysFromUserQuery = [[NSMutableDictionary alloc] init];
                [storysFromUserQuery setObject:[NSNumber numberWithLong:user.ID] forKey:@"user_id"];
                [storysFromUserQuery setObject:@"created_at" forKey:@"sort_desc"];
                [storysFromUserQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
                [storysFromUserQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
                
                [QBRequest objectsWithClassName:@"Story" extendedRequest:storysFromUserQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    // response processing
                    completionBlock(objects);
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];

            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //hashtag
        else if([searchoption integerValue] == 2){
            // Query for Storys with hashtag
            NSMutableDictionary *storysWithHashtagsQuery = [[NSMutableDictionary alloc] init];
            [storysWithHashtagsQuery setObject:searchTerm forKey:@"hashtags"];
            [storysWithHashtagsQuery setObject:@"created_at" forKey:@"sort_desc"];
            [storysWithHashtagsQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
            [storysWithHashtagsQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
            
            [QBRequest objectsWithClassName:@"Story" extendedRequest:storysWithHashtagsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                completionBlock(objects);
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //titel
        else if([searchoption integerValue] == 3){
            // Query for Storys with title
            NSMutableDictionary *titleQuery = [[NSMutableDictionary alloc] init];
            [titleQuery setObject:searchTerm forKey:@"title"];
            [titleQuery setObject:@"created_at" forKey:@"sort_desc"];
            [titleQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
            [titleQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
            
            [QBRequest objectsWithClassName:@"Story" extendedRequest:titleQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                completionBlock(objects);
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //all --ordert by score--
        else{
            NSMutableDictionary *allQuery = [[NSMutableDictionary alloc] init];
            [allQuery setObject:@"score" forKey:@"sort_desc"];
            [allQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
            [allQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
            
            [QBRequest objectsWithClassName:@"Story" extendedRequest:allQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                completionBlock(objects);
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
    }
    //Friends
    else if([groupe integerValue] == 1){
        //User
        if([searchoption integerValue] == 1){
            //Quey for User with Username
            [QBRequest userWithLogin:searchTerm successBlock:^(QBResponse *response, QBUUser *user) {
                // response processing
                // Query for friends with user
                NSMutableDictionary *friendsQuery = [[NSMutableDictionary alloc] init];
                [friendsQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
                [friendsQuery setObject:@"friend" forKey:@"type"];
                [friendsQuery setObject:[NSNumber numberWithLong:user.ID] forKey:@"_parent_id"];
                
                [QBRequest objectsWithClassName:@"Activity" extendedRequest:friendsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    // response processing
                    NSMutableArray *ids = [[NSMutableArray alloc] init];
                    for(QBCOCustomObject *customObject in objects){
                        [ids addObject:customObject.ID];
                    }
                    // Query for Storys from Friends
                    NSMutableDictionary *storysFromFriendsQuery = [[NSMutableDictionary alloc] init];
                    [storysFromFriendsQuery setObject:ids forKey:@"user_id[in]"];
                    [storysFromFriendsQuery setObject:@"created_at" forKey:@"sort_desc"];
                    [storysFromFriendsQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
                    [storysFromFriendsQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
                    
                    [QBRequest objectsWithClassName:@"Story" extendedRequest:storysFromFriendsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                        // response processing
                        completionBlock(objects);
                    } errorBlock:^(QBResponse *response) {
                        // error handling
                        NSLog(@"Response error: %@", [response.error description]);
                    }];
                    
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //hashtag
        else if([searchoption integerValue] == 2){
            // Query for friends
            NSMutableDictionary  *friendsQuery = [[NSMutableDictionary alloc] init];
            [friendsQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
            [friendsQuery setObject:@"friend" forKey:@"type"];
            
            [QBRequest objectsWithClassName:@"Activity" extendedRequest:friendsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                NSMutableArray *ids = [[NSMutableArray alloc] init];
                for(QBCOCustomObject *customObject in objects){
                    [ids addObject:customObject.ID];
                }
                // Query for Storys from Friends with Hashtag
                NSMutableDictionary *storysFromFriendsWithHashtagQuery = [[NSMutableDictionary alloc] init];
                [storysFromFriendsWithHashtagQuery setObject:ids forKey:@"user_id[in]"];
                [storysFromFriendsWithHashtagQuery setObject:searchTerm forKey:@"hashtags"];
                [storysFromFriendsWithHashtagQuery setObject:@"created_at" forKey:@"sort_desc"];
                [storysFromFriendsWithHashtagQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
                [storysFromFriendsWithHashtagQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
                
                [QBRequest objectsWithClassName:@"Story" extendedRequest:storysFromFriendsWithHashtagQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    // response processing
                    completionBlock(objects);
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //titel
        else if([searchoption integerValue] == 3){
            // Query for friends
            NSMutableDictionary  *friendsQuery = [[NSMutableDictionary alloc] init];
            [friendsQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
            [friendsQuery setObject:@"friend" forKey:@"type"];
            
            [QBRequest objectsWithClassName:@"Activity" extendedRequest:friendsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                NSMutableArray *ids = [[NSMutableArray alloc] init];
                for(QBCOCustomObject *customObject in objects){
                    [ids addObject:customObject.ID];
                }
                // Query for Storys from Friends with Title
                NSMutableDictionary *storysFromFriendsWithTitleQuery = [[NSMutableDictionary alloc] init];
                [storysFromFriendsWithTitleQuery setObject:ids forKey:@"user_id[in]"];
                [storysFromFriendsWithTitleQuery setObject:searchTerm forKey:@"title"];
                [storysFromFriendsWithTitleQuery setObject:@"created_at" forKey:@"sort_desc"];
                [storysFromFriendsWithTitleQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
                [storysFromFriendsWithTitleQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
                
                [QBRequest objectsWithClassName:@"Story" extendedRequest:storysFromFriendsWithTitleQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    // response processing
                    completionBlock(objects);
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //all
        else{
            // Query for friends
            NSMutableDictionary  *friendsQuery = [[NSMutableDictionary alloc] init];
            [friendsQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
            [friendsQuery setObject:@"friend" forKey:@"type"];
            
            [QBRequest objectsWithClassName:@"Activity" extendedRequest:friendsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                NSMutableArray *ids = [[NSMutableArray alloc] init];
                for(QBCOCustomObject *customObject in objects){
                    [ids addObject:customObject.ID];
                }
                NSMutableDictionary *storysFromFriendsQuery = [[NSMutableDictionary alloc] init];
                [storysFromFriendsQuery setObject:ids forKey:@"user_id[in]"];
                [storysFromFriendsQuery setObject:@"created_at" forKey:@"sort_desc"];
                [storysFromFriendsQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
                [storysFromFriendsQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
                
                [QBRequest objectsWithClassName:@"Story" extendedRequest:storysFromFriendsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    // response processing
                    completionBlock(objects);
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
    }
    //Mine
    else if([groupe integerValue] == 2){
        //hashtag
        if([searchoption integerValue] == 2){
            // Query for my Storys with hashtag
            NSMutableDictionary *myStorysWithHashtagsQuery = [[NSMutableDictionary alloc] init];
            [myStorysWithHashtagsQuery setObject:searchTerm forKey:@"hashtags"];
            [myStorysWithHashtagsQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
            [myStorysWithHashtagsQuery setObject:@"created_at" forKey:@"sort_desc"];
            [myStorysWithHashtagsQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
            [myStorysWithHashtagsQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
            
            [QBRequest objectsWithClassName:@"Story" extendedRequest:myStorysWithHashtagsQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                completionBlock(objects);
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //titel
        else if([searchoption integerValue] == 3){
            // Query for my Storys with title
            NSMutableDictionary *myTitleQuery = [[NSMutableDictionary alloc] init];
            [myTitleQuery setObject:searchTerm forKey:@"title"];
            [myTitleQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
            [myTitleQuery setObject:@"created_at" forKey:@"sort_desc"];
            [myTitleQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
            [myTitleQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
            
            [QBRequest objectsWithClassName:@"Story" extendedRequest:myTitleQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                completionBlock(objects);
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
        //all
        else{
            // Query for my Storys
            NSMutableDictionary *myStorysQuery = [[NSMutableDictionary alloc] init];
            [myStorysQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
            [myStorysQuery setObject:@"created_at" forKey:@"sort_desc"];
            [myStorysQuery setObject:[NSNumber numberWithInt:offset] forKey:@"skip"];
            [myStorysQuery setObject:[NSNumber numberWithInt:MAX_RESULTS+1] forKey:@"limit"];
            
            [QBRequest objectsWithClassName:@"Story" extendedRequest:myStorysQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                completionBlock(objects);
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
    }
    
}

-(void)queryForStoryFriend:(QBCOCustomObject*)story onCompletion:(ResponseBlock)completionBlock{;
    
    NSMutableDictionary *storyOwnerIsFriendQuery = [[NSMutableDictionary alloc] init];
    [storyOwnerIsFriendQuery setObject:[NSNumber numberWithLong:story.userID] forKey:@"user_id"];
    [storyOwnerIsFriendQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"_parent_id"];
    [storyOwnerIsFriendQuery setObject:@"friend" forKey:@"type"];
    [QBRequest objectsWithClassName:@"Activity" extendedRequest:storyOwnerIsFriendQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        completionBlock(objects);
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void)queryForStoryPage:(QBCOCustomObject*)story onCompletion:(ResponseBlock)completionBlock{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:story.ID forKey:@"_parent_id"];
    [query setObject:@"created_at" forKey:@"sort_asc"];
    [QBRequest objectsWithClassName:@"Photo" extendedRequest:query successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        completionBlock(objects);
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void)queryForUserLike:(QBCOCustomObject*)story onCompletion:(ResponseBlockCount)completionBlock{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:story.ID forKey:@"_parent_id"];
    [query setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
    [query setObject:@"like" forKey:@"type"];
    [QBRequest countObjectsWithClassName:@"Activity" extendedRequest:query successBlock:^(QBResponse *response, NSUInteger count) {
        // response processing
        completionBlock([NSNumber numberWithLong:count]);
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void)queryForUserContribute:(QBCOCustomObject*)story onCompletion:(ResponseBlockCount)completionBlock{
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    [query setObject:story.ID forKey:@"_parent_id"];
    [query setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
    [query setObject:@"contribute" forKey:@"type"];
    [QBRequest countObjectsWithClassName:@"Activity" extendedRequest:query successBlock:^(QBResponse *response, NSUInteger count) {
        // response processing
        completionBlock([NSNumber numberWithLong:count]);
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void)queryForNotifications:(NSNumber*)option onCompletion:(ResponseBlock)completionBlock{
    
    // Notification to my Storys
    if([option integerValue] == 0){
        // Query for my Storys
        NSMutableDictionary *myStorysQuery = [[NSMutableDictionary alloc] init];
        [myStorysQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
        [myStorysQuery setObject:@"updated_at" forKey:@"sort_desc"];
        
        [QBRequest objectsWithClassName:@"Story" extendedRequest:myStorysQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // response processing
            
            //Query for Activitys to Storys
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            for(QBCOCustomObject *customObject in objects){
                [ids addObject:customObject.ID];
            }
            NSMutableArray *types = [[NSMutableArray alloc] init];
            [types addObject:@"like"];
            [types addObject:@"contribute"];
            NSMutableDictionary *activitysFromStorysQuery = [[NSMutableDictionary alloc] init];
            [activitysFromStorysQuery setObject:ids forKey:@"_parent_id[in]"];
            [activitysFromStorysQuery setObject:types forKey:@"type"];
            [activitysFromStorysQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id[ne]"];
            [activitysFromStorysQuery setObject:@"created_at" forKey:@"sort_desc"];
            [activitysFromStorysQuery setObject:[NSNumber numberWithInt:MAX_ACTIVITYS] forKey:@"limit"];
            
            [QBRequest objectsWithClassName:@"Activity" extendedRequest:activitysFromStorysQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                completionBlock(objects);
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
    // Notification contributet Storys
    else if([option integerValue] == 1){
        // Query for my Storys
        NSMutableDictionary *myStorysQuery = [[NSMutableDictionary alloc] init];
        [myStorysQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
        [myStorysQuery setObject:@"updated_at" forKey:@"sort_desc"];
        
        [QBRequest objectsWithClassName:@"Story" extendedRequest:myStorysQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // response processing
            
            NSMutableArray *ids = [[NSMutableArray alloc] init];
            for(QBCOCustomObject *customObject in objects){
                [ids addObject:customObject.ID];
            }
            NSMutableArray *types = [[NSMutableArray alloc] init];
            [types addObject:@"like"];
            [types addObject:@"contribute"];
            
            // Query for my contributet Storys
            NSMutableDictionary *myContrivutetStorysQuery = [[NSMutableDictionary alloc] init];
            [myContrivutetStorysQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
            [myContrivutetStorysQuery setObject:types forKey:@"type"];
            [myContrivutetStorysQuery setObject:ids forKey:@"_parent_id[nin]"];
            [myContrivutetStorysQuery setObject:@"created_at" forKey:@"sort_desc"];
            
            [QBRequest objectsWithClassName:@"Activity" extendedRequest:myContrivutetStorysQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                // response processing
                
                NSMutableArray *ids = [[NSMutableArray alloc] init];
                for(QBCOCustomObject *customObject in objects){
                    [ids addObject:customObject.ID];
                }
                NSMutableArray *types = [[NSMutableArray alloc] init];
                [types addObject:@"like"];
                [types addObject:@"contribute"];;
                
                //Query for Activitys that are not from the User
                NSMutableDictionary *activitysQuery = [[NSMutableDictionary alloc] init];
                [activitysQuery setObject:ids forKey:@"_parent_id[nin]"];
                [activitysQuery setObject:types forKey:@"type"];
                [activitysQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id[ne]"];
                [activitysQuery setObject:@"created_at" forKey:@"sort_desc"];
                [activitysQuery setObject:[NSNumber numberWithInt:MAX_ACTIVITYS] forKey:@"limit"];
                
                [QBRequest objectsWithClassName:@"Activity" extendedRequest:activitysQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    // response processing
                    completionBlock(objects);
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
    // Friend Requests
    else if([option integerValue] == 2){
        
        NSMutableDictionary *frindRequestQuery = [[NSMutableDictionary alloc] init];
        [frindRequestQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"_parent_id"];
        [frindRequestQuery setObject:@"friend" forKey:@"type"];
        [frindRequestQuery setObject:@"created_at" forKey:@"sort_desc"];
        [frindRequestQuery setObject:[NSNumber numberWithInt:MAX_ACTIVITYS] forKey:@"limit"];
        
        [QBRequest objectsWithClassName:@"Activity" extendedRequest:frindRequestQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // response processing
            completionBlock(objects);
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }

}

-(void)queryForFriends: (ResponseBlock)completionBlock{
    NSMutableDictionary *frindQuery = [[NSMutableDictionary alloc] init];
    [frindQuery setObject:[NSString stringWithFormat:@"%li",[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
    [frindQuery setObject:@"friend" forKey:@"type"];
    
    [QBRequest objectsWithClassName:@"Activity" extendedRequest:frindQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        completionBlock(objects);
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void)queryForFriendRequest:(QBUUser*)user onCompletion:(ResponseBlock)completionBlock{
    NSMutableDictionary *frindRequestQuery = [[NSMutableDictionary alloc] init];
    [frindRequestQuery setObject:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]] forKey:@"user_id"];
    [frindRequestQuery setObject:[NSNumber numberWithLong:user.ID] forKey:@"_parent_id"];
    [frindRequestQuery setObject:@"friend" forKey:@"type"];
    
    [QBRequest objectsWithClassName:@"Activity" extendedRequest:frindRequestQuery successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        completionBlock(objects);
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
 
}

@end
