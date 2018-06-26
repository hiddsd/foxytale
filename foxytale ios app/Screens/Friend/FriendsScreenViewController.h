//
//  FriendsScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 12.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>


@interface FriendsScreenViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tabelView;

@property (nonatomic,retain) NSMutableDictionary *tblDictionary;
@property (nonatomic,retain)NSMutableArray *keyArray;
@property (nonatomic,retain)NSMutableArray *tableArray;
@property (nonatomic,retain)NSMutableArray *filteredArray;
@property (weak, nonatomic) IBOutlet UILabel *addFriendNotificationLabel;


@property (nonatomic, assign) UIBackgroundTaskIdentifier friendAcceptBackgroundTaskId;

- (IBAction)shoudAddFriend:(id)sender;



@end
