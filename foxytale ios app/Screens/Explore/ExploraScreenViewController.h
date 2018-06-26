//
//  ExploraScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThumbnailView.h"
#import "CustomPullToRefresh.h"

@interface ExploraScreenViewController : UIViewController <ThumbnailViewDelegate, UISearchBarDelegate, UIScrollViewDelegate, CustomPullToRefreshDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    CustomPullToRefresh *_ptr;
}

@property (weak, nonatomic) IBOutlet UIScrollView* listView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
- (IBAction)changeSeg:(id)sender;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *searchProgressText;
@property NSNumber *option;
@property NSNumber *searchoption;
@property NSString *searchTerm;
@property NSString *searchBarText;
@property (nonatomic, assign) UIBackgroundTaskIdentifier profileImageUploadBackgroundTaskId;

- (IBAction)showOptionsMenue:(id)sender;




@end
