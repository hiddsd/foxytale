//
//  ExplorPhotoScreenViewController.h
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"

@interface ExplorPhotoScreenViewController : UIViewController 
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) NSArray *pictureItemArray;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSArray *cordinates;
@property int cellIndex;
@property float sizeWeidth;
@property float sizeHeight;
@property (weak, nonatomic) IBOutlet UIButton *username;
- (IBAction)goToUserProvile:(id)sender;


@end
