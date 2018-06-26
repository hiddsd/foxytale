//
//  ScoreCalculater.h
//  StoryStrips
//
//  Created by Chris on 03.06.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreCalculater : NSObject

+(ScoreCalculater*)sharedInstance;

-(NSNumber*) calculateScore:(NSNumber*)likes date:(NSDate*)date;

@end
