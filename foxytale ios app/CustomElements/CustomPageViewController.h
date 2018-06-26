//
//  CustomPageViewController.h
//  StoryStrips
//
//  Created by Chris on 11.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomPageViewController : UIPageViewController <UIGestureRecognizerDelegate>

-(void)disablePaging;
-(void)enablePaging;
+(CustomPageViewController*)getSharedInstance;
-(void)disableBorderPaging;


@end
