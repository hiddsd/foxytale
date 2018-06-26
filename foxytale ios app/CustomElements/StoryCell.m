//
//  StoryCell.m
//  StoryStrips
//
//  Created by Chris on 25.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "StoryCell.h"


@implementation StoryCell

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
    
    
    self.imageView = [[UIImageView alloc] initWithFrame:frame];
    //self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    //[self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    //[self.imageView setBackgroundColor:[UIColor blackColor]];
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
