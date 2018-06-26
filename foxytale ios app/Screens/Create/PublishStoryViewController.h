//
//  PublishStoryViewController.h
//  StoryStrips
//
//  Created by Chris on 07.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishStoryViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITextView *storyDescription;
@property (weak, nonatomic) IBOutlet UITableView *contributers;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (retain, nonatomic) NSString *storyTitel;
@property (retain, nonatomic) NSMutableArray *storyItems;

//@property UIProgressView *progressView;

@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier thumbnailUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier storyPostBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;

- (IBAction)postStory:(id)sender;

@end
