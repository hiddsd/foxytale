//
//  ThumbnailView.h
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

//1 layout config
#define kThumbSide 90
#define kThumbSide6 108
#define kThumbSide6plus 121

#define kPadding 10




//2 define the thumb delegate protocol
@protocol ThumbnailViewDelegate <NSObject>
-(void)didSelectPhoto:(id)sender;
@end

//3 define the thumb view interface
@interface ThumbnailView : UIButton
@property (assign, nonatomic) id<ThumbnailViewDelegate> delegate;
@property (assign, nonatomic) NSInteger contributer;
@property (assign, nonatomic) PFObject *story;
@property (assign, nonatomic) BOOL openForUser;
-(id)initWithIndex:(int)i andData:(PFObject*)data andSpacing:(int)space;
@end
