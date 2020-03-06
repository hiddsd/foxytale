//
//  PageStoryViewController.h
//  StoryStrips
//
//  Created by Chris on 11.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ExplorStoryScreenViewController.h"
#import "CustomPageViewController.h"
#import "UIProgressView+AFNetworking.h"

@interface PageStoryViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) NSNumber* IdStory;
@property (nonatomic, assign) NSInteger contributer;

@property (strong, nonatomic) CustomPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contributButton;
@property (weak, nonatomic) IBOutlet UIView *storyView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property UIProgressView *progressView;

- (IBAction)contributeToStory:(id)sender;
- (IBAction)like:(id)sender;

@end
