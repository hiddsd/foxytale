//
//  PageStoryViewController.m
//  StoryStrips
//
//  Created by Chris on 11.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "PageStoryViewController.h"
#import "ExplorStoryScreenViewController.h"
#import "PhotoScreenViewController.h"
#import "UIAlertView+error.h"
//#import "CustomPageViewController.h"
#import "QuickbloxCumunicator.h"
#import "ScoreCalculater.h"
#import "SSUUserCache.h"

#define PICTURE_LIMIT 100

@interface PageStoryViewController (){
    NSMutableArray *_storyItems;
    NSInteger pagecount;
    BOOL pictureAdded;
    QBCOFile *photoFile;
}

@end

@implementation PageStoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



-(void)initialize{
    
    if([_storyItems count] >= PICTURE_LIMIT){
        self.contributButton.enabled = NO;
    }
    
    pagecount = ceil(((float)[_storyItems count]) / ((float) 4));
    
    // Create page view controller
    //self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController = [CustomPageViewController getSharedInstance];
    self.pageViewController.dataSource = self;
    [self.pageViewController disableBorderPaging];
    
    ExplorStoryScreenViewController *startingViewController=nil;
    
    if(pictureAdded){
        startingViewController = [self viewControllerAtIndex:pagecount-1];
    }
    else{
        startingViewController = [self viewControllerAtIndex:0];
    }
    
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.storyView.frame.size.width, self.storyView.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.storyView addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    /*
    for (UIGestureRecognizer *recognizer in self.pageViewController.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }*/

    
}

-(void)install{
    
    [[QuickbloxCumunicator sharedInstance] queryForStoryPage:_story onCompletion:^(NSArray *objects) {
        _storyItems = [objects mutableCopy];
        [self initialize];
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if(self.openForUser){
        self.contributButton.enabled = TRUE;
    }
    else{
        self.contributButton.enabled = FALSE;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GoBackToStory"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"StoryItem to contribute"
                                               object:nil];
    
    [[QuickbloxCumunicator sharedInstance] queryForUserLike:_story onCompletion:^(NSNumber *count) {
        if([count integerValue] == 0 || count == nil ){
            self.likeButton.enabled =YES;
        }
        else{
            self.likeButton.enabled =NO;
        }
    }];
    
    [self install];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];    
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"StoryItem to contribute"]) {
        NSDictionary *dic = [notification userInfo];
        [self shoudAddToStory:[dic valueForKey:@"storyItem"]];
    }
    else if([[notification name] isEqualToString:@"GoBackToStory"]) {
        NSDictionary *dic = [notification userInfo];
        int index = (int)[[dic valueForKey:@"pictureIndex"]integerValue];
        
        //Load Storypage the picture is on        
        int pageindex = ceil(((float)index + 1) / ((float) 4)) - 1;

        ExplorStoryScreenViewController *startingViewController = [self viewControllerAtIndex:pageindex];
        NSArray *viewControllers = @[startingViewController];
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    if([[self.navigationController viewControllers] indexOfObject:self] == NSNotFound){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LeaveStorry"
                                                            object:self
                                                          userInfo:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"fractionCompleted"]) {
        NSProgress *progress = (NSProgress *)object;
        //NSLog(@"Progress… %f", progress.fractionCompleted);
        dispatch_async(dispatch_get_main_queue(), ^(void){
           [_progressView setProgress:progress.fractionCompleted animated:YES];
        });
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(void)shoudAddToStory:(StoryItem*)storyItem{
    // Create the QBCOFile and store it in properties since we'll need it later
    QBCOFile *file = [QBCOFile file];
    file.name = [[_story fields] objectForKey:@"title"];
    file.contentType = @"image/png";
    file.data = storyItem.imageData;
    photoFile = file;
    
    // Check if user is creator
    if([[[self.story fields] objectForKey:@"user_id"] isEqualToNumber:[NSNumber numberWithLong:[[[SSUUserCache instance]currentUser]ID]]]){
        [self addToStory:1];
    }
    else{
        // Check if User allready contributet to story
        [[QuickbloxCumunicator sharedInstance] queryForUserContribute:_story onCompletion:^(NSNumber *count) {
            [self addToStory:(int)count];
        }];
    }
}

-(void)addToStory:(int)contribute{
    // CalculateScore
    ScoreCalculater *calculator = [ScoreCalculater sharedInstance];
    NSNumber *score = [calculator calculateScore:[[_story fields] objectForKey:@"likes"] date:[NSDate date]];
    
    // Update Story object
    [_story.fields setObject:score forKey:@"score"];
    if(contribute == 0){
        NSNumber *count = [NSNumber numberWithInt:[[[_story fields] objectForKey:@"contributers"] intValue] + 1];
        [_story.fields setObject:count forKey:@"contributers"];
    }
    
    [QBRequest updateObject:_story successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        
        //Create Photo object
        QBCOCustomObject *photoObject = [QBCOCustomObject customObject];
        photoObject.className = @"Photo";
        (photoObject.fields)[@"_parent_id"] = object.ID;
        
        [QBRequest createObject:photoObject successBlock:^(QBResponse *response, QBCOCustomObject *photoObject) {
            
            // Upload file to QuickBlox server
            [QBRequest uploadFile:photoFile className:@"Photo" objectID:photoObject.ID fileFieldName:@"image" successBlock:^(QBResponse *response, QBCOFileUploadInfo *inf) {
                // uploaded
                pictureAdded = true;
                [self install];
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress
            } errorBlock:^(QBResponse *response) {
                // error handling
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
        //Create Activity object
        QBCOCustomObject *activityObject = [QBCOCustomObject customObject];
        activityObject.className = @"Activity";
        (activityObject.fields)[@"_parent_id"] = object.ID;
        (activityObject.fields)[@"type"] = @"contribute";
        
        [QBRequest createObject:activityObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ExplorStoryScreenViewController*) viewController).pageIndex;

    if(index == 0){
        [self goToLastPage];
        return nil;
    }
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ExplorStoryScreenViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == pagecount) {
        [self goToFirstPage];
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (ExplorStoryScreenViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if ((pagecount == 0) || (index >= pagecount)) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ExplorStoryScreenViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    pageContentViewController.storyItems = _storyItems;
    pageContentViewController.story = _story;
    pageContentViewController.pageIndex = index;
    pageContentViewController.pageNumberString = [NSString stringWithFormat:@"%d/%ld",(int)index +1,(long)pagecount];
    
    self.title = [[_story fields] objectForKey:@"title"];
    
    return pageContentViewController;
}



- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return pagecount;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    int currentPage = (int)[[pageViewController.viewControllers objectAtIndex:0] pageIndex];
    return currentPage;
}

- (void)goToFirstPage {
    // Instead get the view controller of the first page
    ExplorStoryScreenViewController *newInitialViewController = (ExplorStoryScreenViewController *) [self viewControllerAtIndex:0];
    NSArray *initialViewControllers = [NSArray arrayWithObject:newInitialViewController];
    // Do the setViewControllers: again but this time use direction animation:
    [self.pageViewController setViewControllers:initialViewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

- (void)goToLastPage {
    // Instead get the view controller of the first page
    ExplorStoryScreenViewController *newInitialViewController = (ExplorStoryScreenViewController *) [self viewControllerAtIndex:pagecount-1];
    NSArray *initialViewControllers = [NSArray arrayWithObject:newInitialViewController];
    // Do the setViewControllers: again but this time use direction animation:
    [self.pageViewController setViewControllers:initialViewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (IBAction)contributeToStory:(id)sender {
    [self performSegueWithIdentifier:@"contribute_to_story" sender:self];
}


- (IBAction)like:(id)sender {
    
    NSNumber *likes = [NSNumber numberWithInt:[[[_story fields] objectForKey:@"likes"] intValue] + 1];
    
    // CalculateScore
    ScoreCalculater *calculator = [ScoreCalculater sharedInstance];
    NSNumber *score = [calculator calculateScore:likes date:[_story updatedAt]];
    
    // Update Story object
    [_story.fields setObject:score forKey:@"score"];
    [_story.fields setObject:likes forKey:@"likes"];
    
    [QBRequest updateObject:_story successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        
        //Create Activity object
        QBCOCustomObject *activityObject = [QBCOCustomObject customObject];
        activityObject.className = @"Activity";
        (activityObject.fields)[@"_parent_id"] = object.ID;
        (activityObject.fields)[@"type"] = @"like";
        
        [QBRequest createObject:activityObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            
        } errorBlock:^(QBResponse *response) {
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
        self.likeButton.enabled = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"likeStory"
                                                            object:self
                                                          userInfo:nil];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"contribute_to_story" compare: segue.identifier]==NSOrderedSame) {
        
        PhotoScreenViewController *photoScreenViewController = (PhotoScreenViewController *)segue.destinationViewController;
        
        photoScreenViewController.contributeToStory = YES;
    }
}
@end
