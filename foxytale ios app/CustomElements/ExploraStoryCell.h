//
//  ExploraStoryCell.h
//  StoryStrips
//
//  Created by Chris on 06.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface ExploraStoryCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet PFImageView *imageView;
-(void)setupImageView:(CGRect)frame;
@end
