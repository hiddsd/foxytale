//
//  ThumbnailView.m
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ThumbnailView.h"
#import "ParseCumunicator.h"
#import <ParseUI/ParseUI.h>

@implementation ThumbnailView
@synthesize delegate;
@synthesize contributer;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithIndex:(int)i andData:(PFObject*)data andSpacing:(int)space{
    self = [super init];
    if (self !=nil) {
        //initialize
        
        self.story = data;
        self.contributer = [[data objectForKey:@"open"]integerValue];
        
        int row = i/3;
        int col = i % 3;
        int thumbSide = 0;
        
        
        if ([UIScreen mainScreen].bounds.size.width == 414.0){ //Iphone 6 Plus
            thumbSide = kThumbSide6plus;
        }
        else if ([UIScreen mainScreen].bounds.size.width == 375.0){ //Iphone 6
            thumbSide = kThumbSide6;
        }
        else { //Iphone 5/4
            thumbSide = kThumbSide;
        }
        
        self.frame = CGRectMake(1.5*kPadding+col*(thumbSide+kPadding),space + 1.5*kPadding+row*(thumbSide+kPadding), thumbSide, thumbSide);
        
		//step 2
        //add touch event
        [self addTarget:delegate action:@selector(didSelectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        //load the image
        PFImageView *thumbView = [[PFImageView alloc] init];
        thumbView.file = [data objectForKey:@"thumbnail"];
        [thumbView loadInBackground];
    
        //create Shadow
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.openForUser = false;
        PFObject *creator = [self.story objectForKey:@"creator"];
        if(contributer == 2){
            self.layer.borderColor = [UIColor orangeColor].CGColor;
            self.openForUser = true;
        }
        else if([creator.objectId isEqualToString: [PFUser currentUser].objectId]){
            self.layer.borderColor = [UIColor orangeColor].CGColor;
            self.openForUser = true;
        }
        else if(contributer == 1){
            ParseCumunicator *pc = [[ParseCumunicator alloc] init];
            PFQuery *query = [pc queryForStoryFriend:self.story];
            [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    if(count > 0){
                        self.layer.borderColor = [UIColor orangeColor].CGColor;
                        self.openForUser = true;
                    }
                    else self.layer.borderColor = [UIColor whiteColor].CGColor;
                } else {
                    self.layer.borderColor = [UIColor whiteColor].CGColor;
                }
            }];
        }
        else{
            self.layer.borderColor = [UIColor whiteColor].CGColor;
        }
        
        self.layer.borderWidth = 1.5f;            
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        self.layer.shadowOpacity = 0.25f;

        thumbView.frame = CGRectMake(0,0,thumbSide,thumbSide);
        thumbView.contentMode = UIViewContentModeScaleAspectFit;
        thumbView.backgroundColor = [UIColor whiteColor];
        [self addSubview:thumbView];
    }
    return self;
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
