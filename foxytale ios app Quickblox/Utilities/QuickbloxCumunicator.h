//
//  QuickbloxCumunicator.h
//  StoryStrips
//
//  Created by Chris on 22.09.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <Foundation/Foundation.h>

//API call completion block with result as json
typedef void (^ResponseBlock)(NSArray* objects);
typedef void (^ResponseBlockCount)(NSNumber* count);


@interface QuickbloxCumunicator : NSObject

+(QuickbloxCumunicator*)sharedInstance;

-(void)queryForExplora:(NSNumber*)groupe searchoption:(NSNumber*)searchoption searchTerm:(NSString*)searchTerm pageIndex:(NSNumber*)pageIndex onCompletion:(ResponseBlock)completionBlock;
-(void)queryForStoryFriend:(QBCOCustomObject*)story onCompletion:(ResponseBlock)completionBlock;
-(void)queryForStoryPage:(QBCOCustomObject*)story onCompletion:(ResponseBlock)completionBlock;
-(void)queryForUserLike:(QBCOCustomObject*)story onCompletion:(ResponseBlockCount)completionBlock;
-(void)queryForUserContribute:(QBCOCustomObject*)story onCompletion:(ResponseBlockCount)completionBlock;
-(void)queryForNotifications:(NSNumber*)option onCompletion:(ResponseBlock)completionBlock;
-(void)queryForFriends: (ResponseBlock)completionBlock;
-(void)queryForFriendRequest:(QBUUser*)user onCompletion:(ResponseBlock)completionBlock;
@end
