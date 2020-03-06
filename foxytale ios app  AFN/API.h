//
//  API.h
//  StoryStrips
//
//  Created by Chris on 24.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "AFNetworking.h"

//API call completion block with result as json
typedef void (^JSONResponseBlock)(NSDictionary* json);

@interface API : AFHTTPRequestOperationManager

+(API*)sharedInstance;

-(void)setUser:(NSDictionary*)user password:(NSString*)password;
-(NSDictionary*)getUser;

//check whether there's an authorized user
-(BOOL)isAuthorized;

//send an API command to the server
-(void)commandWithParams:(NSMutableDictionary*)params onCompletion:(JSONResponseBlock)completionBlock;

-(void)logout;

-(NSURL*)urlForImageWithId:(NSNumber*)IdPhoto IdUser:(NSNumber*)IdUser IdStory:(NSNumber*)IdStory isThumb:(BOOL)isThumb;


@end
