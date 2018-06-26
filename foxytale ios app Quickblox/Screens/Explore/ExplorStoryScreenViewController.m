//
//  ExplorStoryScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ExplorStoryScreenViewController.h"
#import "ExploraStoryCell.h"
#import "ExplorPhotoScreenViewController.h"
#import "ZoomInSegue.h"
//#import "CustomPageViewController.h"

#define CELL_SPACING 2.0f

@interface ExplorStoryScreenViewController () {
    BOOL BigPicture;
    UIImageView *imageView;
    float cordinateX;
    float cordinateY;
    float cellSize;
    NSInteger rowindex;
    NSInteger sectionindex;
}

@end

@implementation ExplorStoryScreenViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"LeaveStorry"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"likeStory"
                                               object:nil];
    
    _collectionView.dataSource = self;
    
    self.storyDescription.text = [[_story fields] objectForKey:@"description"];
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", [[_story fields] objectForKey:@"likes"]];
    self.contributersCountLabel.text = [NSString stringWithFormat:@"%@", [[_story fields] objectForKey:@"contributers"]];
    
    self.pageNumber.text = self.pageNumberString;
    
    CGFloat ratio = 1.0;
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.collectionView
                                attribute:NSLayoutAttributeWidth
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.collectionView
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:ratio
                                      constant:0];
    
    NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.collectionView
                                 attribute:NSLayoutAttributeCenterX
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self.view
                                 attribute:NSLayoutAttributeCenterX
                                multiplier:1.0
                                  constant:0];
    
    [self.view addConstraint:constraint1];
    [self.view addConstraint:constraint2];
    
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"LeaveStorry"]) {
        for (NSInteger j = 0; j < [_collectionView numberOfSections]; ++j)
        {
            for (NSInteger i = 0; i < [_collectionView numberOfItemsInSection:j]; ++i)
            {
                ExploraStoryCell *cell = (ExploraStoryCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:j]];
                [cell.imageView cancelImageRequestOperation];
            }
        }
    }
    else if ([[notification name] isEqualToString:@"likeStory"]) {
        NSNumber *likes = [NSNumber numberWithInt:[[[_story fields] objectForKey:@"likes"] intValue]];
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@", likes];
    }
}



- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 4.0;
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if((_pageIndex + 1) *4 <= _storyItems.count){
        return 4;
    }
    else{
        return (4 - (((_pageIndex + 1) * 4) % _storyItems.count));
    }
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ExploraStoryCell *storyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ExploraStoryCellID" forIndexPath:indexPath];
    
    QBCOCustomObject *photoObject = _storyItems[_pageIndex * 4 + indexPath.row];
    
    CGRect frame = storyCell.frame;
    frame.origin.y = 0;
    frame.origin.x = 0;
    [storyCell setupImageView:frame];
    [storyCell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [storyCell.imageView setBackgroundColor:[UIColor blackColor]];
    
    //load the image
    [QBRequest downloadFileFromClassName:@"Photo" objectID:photoObject.ID fileFieldName:@"image"
                            successBlock:^(QBResponse *response, NSData *loadedData) {
                                storyCell.imageView.image = [UIImage imageWithData:loadedData];
                            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                // handle progress
                            } errorBlock:^(QBResponse *error) {
                                // error handling
                                NSLog(@"Response error: %@", [error description]);
                            }];
    
    
    storyCell.layer.masksToBounds = NO;
    storyCell.layer.borderColor = [UIColor whiteColor].CGColor;
    storyCell.layer.borderWidth = 1.5f;
    
    storyCell.layer.shadowColor = [UIColor blackColor].CGColor;
    storyCell.layer.shadowRadius = 1.0f;
    storyCell.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    storyCell.layer.shadowOpacity = 0.25f;
    
    return storyCell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(!BigPicture){
        rowindex = indexPath.row;
        sectionindex = indexPath.section;
        ExploraStoryCell *cell = (ExploraStoryCell *)[collectionView cellForItemAtIndexPath:indexPath];
        imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(self.collectionView.frame.origin.x + cell.frame.origin.x, self.collectionView.frame.origin.y + cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height);
        imageView.layer.masksToBounds = NO;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 1.5f;
        imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        imageView.layer.shadowRadius = 1.0f;
        imageView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
        imageView.layer.shadowOpacity = 0.25f;
        imageView.image = cell.imageView.image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:imageView];
        
        float scal = self.view.frame.size.width / imageView.frame.size.width;
        cordinateX = self.collectionView.frame.origin.x + cell.frame.origin.x;
        cordinateY = self.collectionView.frame.origin.y + cell.frame.origin.y;
        cellSize = cell.frame.size.width;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut
                         animations:^{
                             imageView.frame = CGRectMake(self.collectionView.frame.origin.x + 10, self.collectionView.frame.origin.y, cellSize *scal -20, cellSize *scal -20);
                         }
                         completion:^(BOOL finished){
                             BigPicture = TRUE;
                             [[CustomPageViewController getSharedInstance] disablePaging];
                         }];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if(BigPicture){
        [UIView animateWithDuration:0.4
                          delay:0.0
                        options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut
                     animations:^{
                         imageView.frame = CGRectMake(cordinateX, cordinateY, cellSize, cellSize);
                     }
                     completion:^(BOOL finished){
                         [imageView removeFromSuperview];
                         BigPicture = FALSE;
                         [[CustomPageViewController getSharedInstance] enablePaging];
                     }];
    }
}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
   if(BigPicture){
       rowindex++;
       int itemNumber;
       if((_pageIndex + 1) *4 <= _storyItems.count){
           itemNumber = 4;
       }
       else{
           itemNumber = (4 - (((_pageIndex + 1) * 4) % _storyItems.count));
       }
       if(rowindex < itemNumber){
           ExploraStoryCell *cell = (ExploraStoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:rowindex inSection:sectionindex]];
           imageView.image = cell.imageView.image;
           cordinateX = self.collectionView.frame.origin.x + cell.frame.origin.x;
           cordinateY = self.collectionView.frame.origin.y + cell.frame.origin.y;
       }
       else{
           [imageView removeFromSuperview];
           BigPicture = FALSE;
           [[CustomPageViewController getSharedInstance] enablePaging];
           NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:_pageIndex] forKey:@"pageIndex"];
           [[NSNotificationCenter defaultCenter] postNotificationName:@"nextpage"
                                                               object:self
                                                             userInfo:dict];
       }
   }
}

- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    if(BigPicture){
        if(rowindex > 0){
            rowindex--;
            ExploraStoryCell *cell = (ExploraStoryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:rowindex inSection:sectionindex]];
            imageView.image = cell.imageView.image;
            cordinateX = self.collectionView.frame.origin.x + cell.frame.origin.x;
            cordinateY = self.collectionView.frame.origin.y + cell.frame.origin.y;
        }
        else{
            [imageView removeFromSuperview];
            BigPicture = FALSE;
            [[CustomPageViewController getSharedInstance] enablePaging];
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:_pageIndex]  forKey:@"pageIndex"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"previospage"
                                                                object:self
                                                              userInfo:dict];
        }
    }
}*/




#pragma mark - Prepare for Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ExploraStoryCell *cell = (ExploraStoryCell *)sender;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    //
    ((ZoomInSegue *)segue).index = indexPath;
    //
    
    ExplorPhotoScreenViewController *explorPhotoScreenViewController = (ExplorPhotoScreenViewController *)segue.destinationViewController;
    
    explorPhotoScreenViewController.pictureItemArray = _storyItems;
    explorPhotoScreenViewController.index = _pageIndex * 4 + indexPath.row;
    
    NSDictionary *element0 = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat: self.collectionView.frame.origin.x], @"cordinateX", [NSNumber numberWithFloat:self.collectionView.frame.origin.y], @"cordinateY", nil];
    NSDictionary *element1 = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat: self.collectionView.frame.origin.x + cell.frame.size.width + CELL_SPACING], @"cordinateX", [NSNumber numberWithFloat:self.collectionView.frame.origin.y], @"cordinateY", nil];
    NSDictionary *element2 = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat: self.collectionView.frame.origin.x], @"cordinateX", [NSNumber numberWithFloat:self.collectionView.frame.origin.y +cell.frame.size.height + CELL_SPACING], @"cordinateY", nil];
    NSDictionary *element3 = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithFloat: self.collectionView.frame.origin.x + cell.frame.size.width + CELL_SPACING], @"cordinateX", [NSNumber numberWithFloat:self.collectionView.frame.origin.y +cell.frame.size.height + CELL_SPACING], @"cordinateY", nil];
    
    NSArray *cordinates = [[NSArray alloc] initWithObjects:element0,element1,element2,element3,nil];
    
    
    explorPhotoScreenViewController.cordinates = cordinates;
    explorPhotoScreenViewController.cellIndex = (int)indexPath.row;
    explorPhotoScreenViewController.sizeHeight = cell.frame.size.height;
    explorPhotoScreenViewController.sizeWeidth = cell.frame.size.width;

}



@end
