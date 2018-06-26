//
//  PhotoScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 25.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "StoryItem.h"

@interface PhotoScreenViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (nonatomic, strong)  StoryItem *storyItem;
@property (weak, nonatomic) IBOutlet UITextView *photoText;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addStripButton;
@property (nonatomic)NSInteger index;
@property BOOL contributeToStory;

- (IBAction)takePhoto:(id)sender;
- (IBAction)selectPhoto:(id)sender;
- (IBAction)savePicture:(id)sender;

//- (IBAction)effect:(id)sender;

@end
