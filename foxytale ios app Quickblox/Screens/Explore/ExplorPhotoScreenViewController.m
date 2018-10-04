//
//  ExplorPhotoScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ExplorPhotoScreenViewController.h"
#import "ExploraScreenViewController.h"

@interface ExplorPhotoScreenViewController (){
}

@end

@implementation ExplorPhotoScreenViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationItem setHidesBackButton:YES animated:NO];
    self.tabBarController.tabBar.hidden = YES;
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationItem setHidesBackButton:NO animated:NO];
    self.tabBarController.tabBar.hidden = NO;
    [self.imageView cancelImageRequestOperation];
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //create Shadow
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 1.5f;
    
    self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.imageView.layer.shadowRadius = 1.0f;
    self.imageView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.imageView.layer.shadowOpacity = 0.25f;
    
    [self setupImageView];
    
    // Add swipeGestures
    UISwipeGestureRecognizer *oneFingerSwipeLeft = [[UISwipeGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(oneFingerSwipeLeft:)];
    [oneFingerSwipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeLeft];
    
    UISwipeGestureRecognizer *oneFingerSwipeRight = [[UISwipeGestureRecognizer alloc]
                                                      initWithTarget:self
                                                      action:@selector(oneFingerSwipeRight:)];
    [oneFingerSwipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeRight];
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                          initWithTarget:self
                                                          action:@selector(handleSingleTap:)];
    [singleTapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    CGFloat ratio = 1.0;
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.imageView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.imageView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:ratio
                                                                    constant:0];
    
    
    [self.view addConstraint:constraint1];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    NSDictionary *cellCordinates = [self.cordinates objectAtIndex:_cellIndex];
    float cordinateY = [[cellCordinates objectForKey:@"cordinateY"] floatValue];
    float cordinateX = [[cellCordinates objectForKey:@"cordinateX"] floatValue];
        [UIView animateWithDuration:0.4
                          delay:0.0
                        options:(UIViewAnimationOptions)UIViewAnimationCurveEaseOut
                     animations:^{
                         self.imageView.frame = CGRectMake(cordinateX, cordinateY, self.sizeWeidth, self.sizeHeight);
                     }
                     completion:^(BOOL finished){
                         NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:(int)_index] forKey:@"pictureIndex"];
                         [[NSNotificationCenter defaultCenter] postNotificationName:@"GoBackToStory"
                                                                             object:self
                                                                           userInfo:dict];
                         [self.navigationController popViewControllerAnimated:NO];
                     }];
}

- (void)oneFingerSwipeLeft:(UITapGestureRecognizer *)recognizer {
    if(_index < _pictureItemArray.count -1){
        _index++;
        if(_cellIndex < 3)_cellIndex++;
        else _cellIndex = 0;
        [self setupImageView];
    }
}

- (void)oneFingerSwipeRight:(UITapGestureRecognizer *)recognizer {
    if(_index > 0){
        _index--;
        if(_cellIndex > 0)_cellIndex--;
        else _cellIndex = 3;
        [self setupImageView];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupImageView {
    
    QBCOCustomObject *pictureItem = _pictureItemArray[_index];
    //load the image
    [QBRequest downloadFileFromClassName:@"Photo" objectID:pictureItem.ID fileFieldName:@"image"
                            successBlock:^(QBResponse *response, NSData *loadedData) {
                                self.imageView.image = [UIImage imageWithData:loadedData];
                                [self.imageView setBackgroundColor:[UIColor blackColor]];
                                [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
                            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                // handle progress
                            } errorBlock:^(QBResponse *error) {
                                // error handling
                                NSLog(@"Response error: %@", [error description]);
                            }];
    
    [QBRequest userWithID:pictureItem.userID successBlock:^(QBResponse *response, QBUUser *user) {
        [self.username setTitle:user.login forState:UIControlStateNormal];
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}


- (IBAction)goToUserProvile:(id)sender {
    [self performSegueWithIdentifier:@"userProvile" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"userProvile" compare: segue.identifier]==NSOrderedSame) {
        UIButton *button = (UIButton*)sender;
        UITabBarController *tabController = (UITabBarController*)segue.destinationViewController;
        tabController.selectedIndex = 0;
        UINavigationController *navController = (UINavigationController *)[tabController selectedViewController];
        ExploraScreenViewController *exploraController = (ExploraScreenViewController *)([navController viewControllers][0]);
        exploraController.option = [NSNumber numberWithInt:0];
        exploraController.segment.selectedSegmentIndex = 0;
        exploraController.searchoption = [NSNumber numberWithInt:1];
        exploraController.searchTerm = button.titleLabel.text;
        exploraController.searchBarText = [NSString stringWithFormat:@"@%@", button.titleLabel.text];
        exploraController.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"Search for User %@",nil), button.titleLabel.text];
    }
}

@end
