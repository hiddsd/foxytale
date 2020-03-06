//
//  ExplorStoryScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExplorStoryScreenViewController : UIViewController <UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UITextView *storyDescription;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSInteger contributer;
@property NSUInteger pageIndex;
@property NSMutableArray *storyItems;
@property NSString *pageNumberString;
@property (weak, nonatomic) IBOutlet UILabel *pageNumber;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *contributersCountLabel;

@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;




@end
