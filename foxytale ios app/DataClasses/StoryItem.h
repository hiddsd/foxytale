//
//  StoryItem.h
//  StoryStrips
//
//  Created by Chris on 26.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryItem : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) UIImage *imageWithText;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSData *imageData;

@end
