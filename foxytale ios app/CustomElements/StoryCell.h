//
//  StoryCell.h
//  StoryStrips
//
//  Created by Chris on 25.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StoryCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
-(void)setupImageView:(CGRect)frame;



@end
