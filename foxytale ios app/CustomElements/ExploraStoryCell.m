//
//  ExploraStoryCell.m
//  StoryStrips
//
//  Created by Chris on 06.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ExploraStoryCell.h"
#import <ParseUI/ParseUI.h>

@implementation ExploraStoryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setupImageView];
    }
    return self;
}

-(void)setupImageView:(CGRect)frame {
    self.imageView = [[PFImageView alloc] initWithFrame:frame];
    //self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    // Configure the image view here
    [self addSubview:self.imageView];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
