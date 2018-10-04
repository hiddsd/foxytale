//
//  ThumbnailView.m
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ThumbnailView.h"
#import "SSUUserCache.h"
#import "QuickbloxCumunicator.h"

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

-(id)initWithIndex:(int)i andData:(QBCOCustomObject*)data {
    self = [super init];
    if (self !=nil) {
        //initialize
        
        self.story = data;
        self.contributer = [[[data fields] objectForKey:@"open"]integerValue];
        
        int row = i/3;
        int col = i % 3;
        
        self.frame = CGRectMake(1.5*kPadding+col*(kThumbSide+kPadding), 1.5*kPadding+row*(kThumbSide+kPadding), kThumbSide, kThumbSide);
        
		//step 2
        //add touch event
        [self addTarget:delegate action:@selector(didSelectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        //load the image
        [QBRequest downloadFileFromClassName:@"Story" objectID:data.ID fileFieldName:@"thumbnail"
                                successBlock:^(QBResponse *response, NSData *loadedData) {
                                    UIImageView *thumbView = [[UIImageView alloc] init];
                                    thumbView.frame = CGRectMake(0,0,90,90);
                                    thumbView.contentMode = UIViewContentModeScaleAspectFit;
                                    thumbView.backgroundColor = [UIColor blackColor];
                                    [self addSubview:thumbView];
                                    thumbView.image = [UIImage imageWithData:loadedData];
                                } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                    // handle progress
                                } errorBlock:^(QBResponse *error) {
                                    // error handling
                                    NSLog(@"Response error: %@", [error description]);
                                }];
        
        //create Shadow
        self.backgroundColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        
        self.openForUser = false;
        NSNumber *creator = [[data fields] objectForKey:@"user_id"];
        if(contributer == 2){
            self.layer.borderColor = [UIColor orangeColor].CGColor;
            self.openForUser = true;
        }
        else if([creator integerValue] == [[[SSUUserCache instance]currentUser]ID]){
            self.layer.borderColor = [UIColor orangeColor].CGColor;
            self.openForUser = true;
        }
        else if(contributer == 1){
            QuickbloxCumunicator *qbc = [QuickbloxCumunicator sharedInstance];
            [qbc queryForStoryFriend:self.story onCompletion:^(NSArray *objects) {
                if(objects.count == 0 || objects == nil ){
                    self.layer.borderColor = [UIColor whiteColor].CGColor;
                }
                else{
                    self.layer.borderColor = [UIColor orangeColor].CGColor;
                    self.openForUser = true;
                }
            }];
        }
        self.layer.borderWidth = 1.5f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        self.layer.shadowOpacity = 0.25f;

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

