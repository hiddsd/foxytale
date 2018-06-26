//
//  ScoreCalculater.m
//  StoryStrips
//
//  Created by Chris on 03.06.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ScoreCalculater.h"

@implementation ScoreCalculater

static ScoreCalculater *_sharedInstance = nil;

+(ScoreCalculater*)sharedInstance
{
    if (!_sharedInstance) {
        _sharedInstance = [[self alloc] init];
    }
    return _sharedInstance;
}

-(NSNumber*) calculateScore:(NSNumber*)likes date:(NSDate*)date{
    
    if([likes integerValue] <= 0)likes = [NSNumber numberWithInt:1];
    
    double order = log10([likes doubleValue]);
    double seconds = [date timeIntervalSince1970] - 1134028003;
    double score = order + seconds / 45000;
        
    return [NSNumber numberWithDouble:score];
}

@end
