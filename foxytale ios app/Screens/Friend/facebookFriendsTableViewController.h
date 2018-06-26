//
//  facebookFriendsTableViewController.h
//  Foxytale
//
//  Created by Chris on 16.07.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface facebookFriendsTableViewController : UITableViewController <FBSDKSharingDelegate>
@property (strong, nonatomic) IBOutlet UITableView *FFriendsTable;

@end
