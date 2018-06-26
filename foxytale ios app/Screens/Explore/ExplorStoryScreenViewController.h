//
//  ExplorStoryScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ExplorStoryScreenViewController : UIViewController <UICollectionViewDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *storyDescription;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property NSUInteger pageIndex;
@property NSArray *storyItems;
@property NSString *pageNumberString;
@property PFObject *story;
@property (weak, nonatomic) IBOutlet UILabel *pageNumber;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *contributersCountLabel;
@property (nonatomic, assign) UIBackgroundTaskIdentifier storyDescChangeBackgroundTaskId;

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;





@end
