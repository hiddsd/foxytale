//
//  NotificationCell.h
//  StoryStrips
//
//  Created by Chris on 18.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "TTTAttributedLabel.h"
#import <ParseUI/ParseUI.h>

@interface NotificationCell : UITableViewCell <TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *notificationLabel;
@property (weak, nonatomic) IBOutlet PFImageView *notificationImageView;
@property (weak, nonatomic) IBOutlet PFImageView *storyImageView;
@property PFObject *story;
@property PFUser *user;

-(void)setAtributetLabel:(NSString*)string;

@end
