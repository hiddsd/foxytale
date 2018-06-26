//
//  ProfileView.m
//  Foxytale
//
//  Created by Chris on 04.03.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "ProfileView.h"
#import "ParseCumunicator.h"

@implementation ProfileView

@synthesize friendAcceptBackgroundTaskId;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (id)profileView
{
    ProfileView *profileView = [[[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:nil options:nil] lastObject];
    
    int side = 0;
    int hight = kprofilehight;
    
    if ([UIScreen mainScreen].bounds.size.width == 414.0){ //Iphone 6 Plus
        side = 414;
    }
    else if ([UIScreen mainScreen].bounds.size.width == 375.0){ //Iphone 6
        side = 375;
    }
    else { //Iphone 5/4
        side = 320;
    }
    
    profileView.frame = CGRectMake(0, 10, side, hight);
    
    // make sure customView is not nil or the wrong class!
    if ([profileView isKindOfClass:[ProfileView class]])
        return profileView;
    else
        return nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"ProfileView" owner:self options:nil];
        UIView *mainView = [subviewArray objectAtIndex:0];
        
        int side = 0;
        int hight = kprofilehight;
        
        if ([UIScreen mainScreen].bounds.size.width == 414.0){ //Iphone 6 Plus
            side = 414;
        }
        else if ([UIScreen mainScreen].bounds.size.width == 375.0){ //Iphone 6
            side = 375;
        }
        else { //Iphone 5/4
            side = 320;
        }
        
        mainView.frame = CGRectMake(0, 0, side, hight);
        
        
        [self addSubview:mainView];
    }
    return self;
}

- (IBAction)addToFriends:(id)sender {
    self.addasfriend.enabled = NO;
    //Create Activity
    PFObject *activity = [PFObject objectWithClassName:@"Activity"];
    [activity setObject:[PFUser currentUser] forKey:@"fromUser"];
    [activity setObject:_user forKey:@"toUser"];
    [activity setObject:@"friend" forKey:@"type"];
    
    // Request a background execution task to allow us to finish uploading
    // the activity even if the app is sent to the background
    self.friendAcceptBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.friendAcceptBackgroundTaskId];
    }];
    
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ added you as a Friend",nil), [[PFUser currentUser]username]];
            [PFCloud callFunctionInBackground:@"sendPushToUser"
                               withParameters:@{@"recipientId": _user.objectId, @"message": message}
                                        block:^(NSString *success, NSError *error) {
                                            if (!error) {
                                                // Push sent successfully
                                                NSLog(@"Push success!");
                                            }
                                        }];
           
            [[UIApplication sharedApplication] endBackgroundTask:self.friendAcceptBackgroundTaskId];
            
            self.addasfriend.hidden = YES;
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.addasfriend.frame];
            imgView.image = [UIImage imageNamed:@"checkmark.png"];
            imgView.contentMode = UIViewContentModeCenter;
            [self addSubview:imgView];
            
            //aktualisiere freundes liste
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Friend deleted"
                                                                object:self
                                                              userInfo:nil];
            
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.friendAcceptBackgroundTaskId];
            self.addasfriend.enabled = YES;
        }
    }];
    
}

-(id)initWithData:(PFUser*)user {
    self = [ProfileView profileView];
    if (self !=nil) {
        //initialize
        _user = user;
        
        self.username.text = user.username;        
        self.contributecount.text = @"";
        self.storycount.text = @"";
        
        //Button
        if([user.objectId isEqual:[[PFUser currentUser]objectId]]){
            self.addasfriend.hidden = YES;
            
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
            singleTap.numberOfTapsRequired = 1;
            [self.profilepic setUserInteractionEnabled:YES];
            [self.profilepic addGestureRecognizer:singleTap];
        }
        else {
            ParseCumunicator *pc = [ParseCumunicator sharedInstance];
            PFQuery *query = [pc queryForFriendRequest:(PFUser*)user];
            [query countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
                if (!error) {
                    // The count request succeeded. Log the count
                    if(count == 0){
                        [self.addasfriend setBackgroundColor:[UIColor colorWithRed:85/255.0 green:85/255.0 blue:85/255.0 alpha:1] forState:UIControlStateHighlighted];
                        self.addasfriend.enabled = YES;
                    }
                    else{
                        self.addasfriend.hidden = YES;
                        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.addasfriend.frame];
                        imgView.image = [UIImage imageNamed:@"checkmark.png"];
                        imgView.contentMode = UIViewContentModeCenter;
                        [self addSubview:imgView];
                    }
                } else {
                    // The request failed
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
            }];
        }
        
        //Profile Pic
        self.profilepic.layer.cornerRadius = self.profilepic.frame.size.width / 2;
        self.profilepic.clipsToBounds = YES;
        if([user objectForKey:@"profilepic"] != nil){
            self.profilepic.file = [user objectForKey:@"profilepic"];
            [self.profilepic loadInBackground];
        }
        else{
            self.profilepic.image = [UIImage imageNamed:@"profilepicph"];
        }
        
        
        
        //Count labels
        [PFCloud callFunctionInBackground:@"profile"
                           withParameters:@{@"userId": user.objectId}
                                    block:^(NSArray *success, NSError *error) {
                                        if (!error) {
                                            self.storycount.text = [[success valueForKey:@"storys"]stringValue];
                                            self.contributecount.text = [[success valueForKey:@"conntributes"]stringValue];
                                        }
                                    }];
        
 
    }
    return self;
}

-(void)tapDetected{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeProfilePicture"
                                                        object:self
                                                      userInfo:nil];    
}

-(void)setProfilepicImage:(UIImage*)image{
    self.profilepic.image = image;
}

@end
