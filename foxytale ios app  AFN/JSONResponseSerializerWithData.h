//
//  JSONResponseSerializerWithData.h
//  StoryStrips
//
//  Created by Chris on 03.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "AFURLResponseSerialization.h"

/// NSError userInfo key that will contain response data
static NSString * const JSONResponseSerializerWithDataKey = @"JSONResponseSerializerWithDataKey";

@interface JSONResponseSerializerWithData : AFJSONResponseSerializer

@end
