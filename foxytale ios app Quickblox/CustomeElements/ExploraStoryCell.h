//
//  ExploraStoryCell.h
//  StoryStrips
//
//  Created by Chris on 06.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UIImageView+AFNetworking.h"

@interface ExploraStoryCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
-(void)setupImageView:(CGRect)frame;
@end
