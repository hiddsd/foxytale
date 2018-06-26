//
//  FriendCell.h
//  StoryStrips
//
//  Created by Chris on 13.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendCell : UITableViewCell
- (IBAction)deleteFriend:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *friendName;
@property (weak, nonatomic) QBCOCustomObject *activityObject;

@end
