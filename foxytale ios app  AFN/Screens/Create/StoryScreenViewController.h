//
//  StoryScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 25.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryItem.h"

@interface StoryScreenViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *storyTitel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareStoryButton;




- (IBAction)shareStory:(id)sender;
-(void)addToStory:(StoryItem*)storyItem;


@end
