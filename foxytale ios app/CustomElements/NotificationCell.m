//
//  NotificationCell.m
//  StoryStrips
//
//  Created by Chris on 18.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

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

-(void)setAtributetLabel:(NSString*)string{
    
    
    if([self.notificationImageView gestureRecognizers] == nil){
        
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser)];
        userTap.numberOfTapsRequired = 1;
        [self.notificationImageView setUserInteractionEnabled:YES];
        [self.notificationImageView addGestureRecognizer:userTap];
    }
    
    if(self.story != nil){
        self.storyImageView.hidden = NO;
        if([self.storyImageView gestureRecognizers] == nil){
            UITapGestureRecognizer *storyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStory)];
            storyTap.numberOfTapsRequired = 1;
            [self.storyImageView setUserInteractionEnabled:YES];
            [self.storyImageView addGestureRecognizer:storyTap];
        }
    }
    else{
        self.storyImageView.hidden = YES;
    }
    
    
    //label
    self.notificationLabel.linkAttributes = @{ (id)kCTForegroundColorAttributeName: [UIColor blueColor],
                                 (id)kCTUnderlineStyleAttributeName: [NSNumber numberWithInt:kCTUnderlineStyleNone] };
    self.notificationLabel.delegate = self;
    self.notificationLabel.text = string;
    NSRange r = [string rangeOfString:self.user.username];
    [self.notificationLabel addLinkToURL:[NSURL URLWithString:@"username"] withRange:r];
    self.notificationLabel.userInteractionEnabled=YES;
    
    //Profile Pic
    self.notificationImageView.layer.cornerRadius = self.notificationImageView.frame.size.width / 2;
    self.notificationImageView.clipsToBounds = YES;
    if([self.user objectForKey:@"profilepic"] != nil){
        self.notificationImageView.file = [self.user objectForKey:@"profilepic"];
        [self.notificationImageView loadInBackground];
    }
    else{
        self.notificationImageView.image = [UIImage imageNamed:@"profilepicph"];
    }
    //thumbnail Pic
    if([self.story objectForKey:@"thumbnail"] != nil){
        self.storyImageView.file = [self.story objectForKey:@"thumbnail"];
        [self.storyImageView loadInBackground];
    }
    else{
        self.storyImageView.image = nil;
    }
}

-(void)tapUser{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.user forKey:@"user"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCellUserSelected"
                                                        object:self
                                                      userInfo:dict];
}
-(void)tapStory{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.story forKey:@"story"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationCellStorySelected"
                                                        object:self
                                                      userInfo:dict];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [self tapUser];
}



@end
