//
//  ZoomInSegue.m
//  StoryStrips
//
//  Created by Chris on 19.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ZoomInSegue.h"
#import "QuartzCore/QuartzCore.h"
#import "ExplorPhotoScreenViewController.h"
#import "ExplorStoryScreenViewController.h"
#import "ExploraStoryCell.h"

@implementation ZoomInSegue


-(void)perform {
    
    ExplorStoryScreenViewController *sourceViewController = (ExplorStoryScreenViewController*)[self sourceViewController];
    ExplorPhotoScreenViewController *destinationController = (ExplorPhotoScreenViewController*)[self destinationViewController];
    
    
    ExploraStoryCell *cell = (ExploraStoryCell *)[sourceViewController.collectionView cellForItemAtIndexPath:self.index];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(sourceViewController.collectionView.frame.origin.x + cell.frame.origin.x, sourceViewController.collectionView.frame.origin.y + cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
    UIImage *image = cell.imageView.image;
    imageView.image = image;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    imageView.layer.borderWidth = 1.5f;
    
    imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    imageView.layer.shadowRadius = 1.0f;
    imageView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    imageView.layer.shadowOpacity = 0.25f;
    [sourceViewController.view addSubview:imageView];
    
    float scal = sourceViewController.view.frame.size.width  / imageView.frame.size.width;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut
                     animations:^{
                         imageView.frame = CGRectMake(5, sourceViewController.collectionView.frame.origin.y, cell.frame.size.width *scal -10, cell.frame.size.height *scal -10);
                     }
                     completion:^(BOOL finished){
                         [imageView removeFromSuperview];
                         [sourceViewController.navigationController pushViewController:destinationController animated:NO];                         
                     }];
    
}
@end
