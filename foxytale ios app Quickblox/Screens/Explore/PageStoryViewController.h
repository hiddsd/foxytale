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

@interface PageStoryViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) QBCOCustomObject *story;

@property (strong, nonatomic) CustomPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contributButton;
@property (weak, nonatomic) IBOutlet UIView *storyView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property UIProgressView *progressView;
@property (assign, nonatomic) BOOL openForUser;

- (IBAction)contributeToStory:(id)sender;
- (IBAction)like:(id)sender;

@end
