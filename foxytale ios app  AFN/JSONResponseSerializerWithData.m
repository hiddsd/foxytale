//
//  JSONResponseSerializerWithData.m
//  StoryStrips
//
//  Created by Chris on 03.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "JSONResponseSerializerWithData.h"

@implementation JSONResponseSerializerWithData

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
	id JSONObject = [super responseObjectForResponse:response data:data error:error];
	if (*error != nil) {
		NSMutableDictionary *userInfo = [(*error).userInfo mutableCopy];
		if (data == nil) {
            //			// NOTE: You might want to convert data to a string here too, up to you.
            		userInfo[JSONResponseSerializerWithDataKey] = @"";
			
		} else {
            //			// NOTE: You might want to convert data to a string here too, up to you.
            			userInfo[JSONResponseSerializerWithDataKey] = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
			
		}
		NSError *newError = [NSError errorWithDomain:(*error).domain code:(*error).code userInfo:userInfo];
		(*error) = newError;
	}
    
	return (JSONObject);
}
@end
