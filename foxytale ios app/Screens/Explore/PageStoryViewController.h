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
#import <Parse/Parse.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface PageStoryViewController : UIViewController <UIPageViewControllerDataSource, FBSDKSharingDelegate>

@property (strong, nonatomic) PFObject *story;

@property (strong, nonatomic) CustomPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *contributButton;
@property (weak, nonatomic) IBOutlet UIView *storyView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *likeButton;
@property UIProgressView *progressView;

@property (nonatomic, assign) UIBackgroundTaskIdentifier storyPostBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;


@property (assign, nonatomic) BOOL openForUser;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *optionButton;

- (IBAction)contributeToStory:(id)sender;
- (IBAction)like:(id)sender;


- (IBAction)showOptionsMenu:(id)sender;

@end
