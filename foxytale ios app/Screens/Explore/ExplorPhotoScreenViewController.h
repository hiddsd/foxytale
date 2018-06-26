//
//  ExplorPhotoScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface ExplorPhotoScreenViewController : UIViewController <UIGestureRecognizerDelegate, FBSDKSharingDelegate>
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property (weak, nonatomic) NSArray *pictureItemArray;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSArray *cordinates;
@property int cellIndex;
@property float sizeWeidth;
@property float sizeHeight;
@property PFObject *story;
@property (weak, nonatomic) IBOutlet PFImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *username;
@property (weak, nonatomic) IBOutlet UIToolbar *picteroptionsToolbar;
- (IBAction)goToUserProvile:(id)sender;
- (IBAction)showOptions:(id)sender;


@end
