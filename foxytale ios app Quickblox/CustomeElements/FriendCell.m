//
//  FriendCell.m
//  StoryStrips
//
//  Created by Chris on 13.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "FriendCell.h"

@implementation FriendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)deleteFriend:(id)sender {
    NSLog(@"OBJECT: %@", self.activityObject);
    
    [QBRequest deleteObjectWithID:self.activityObject.ID className:@"Activity" successBlock:^(QBResponse *response) {
        // object deleted
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Friend deleted"
                                                            object:self
                                                          userInfo:nil];
    } errorBlock:^(QBResponse *error) {
        // error handling
        NSLog(@"Response error: %@", error.description);
    }];
}
@end
