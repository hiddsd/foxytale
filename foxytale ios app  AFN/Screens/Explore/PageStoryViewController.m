//
//  PageStoryViewController.m
//  StoryStrips
//
//  Created by Chris on 11.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "PageStoryViewController.h"
#import "API.h"
#import "ExplorStoryScreenViewController.h"
#import "PhotoScreenViewController.h"
#import "UIAlertView+error.h"
//#import "CustomPageViewController.h"

#define PICTURE_LIMIT 60

@interface PageStoryViewController (){
    NSMutableArray *_storyItems;
    NSInteger pagecount;
    BOOL pictureAdded;
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
    
    API *api = [API sharedInstance];
    
    //load the caption of the selected story
    [api commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"stream",@"command",
                            _IdStory,@"IdStory",
                            nil]
     
              onCompletion:^(NSDictionary *json) {
                  _storyItems = [json objectForKey:@"result"];
                  [self initialize];
              }];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    if(self.contributer == 2){
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
    
    
    [self install];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];    
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"StoryItem to contribute"]) {
        NSDictionary *dic = [notification userInfo];
        [self addToStory:[dic valueForKey:@"storyItem"]];
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
    [[[API sharedInstance]operationQueue] cancelAllOperations];
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

-(void)addToStory:(StoryItem*)storyItem{
    //Upload StoryItem
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    UIView *blockView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    blockView.backgroundColor = [UIColor clearColor];
    
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake((blockView.frame.size.width - self.progressView.frame.size.width - 40)/2,
                                                                      (blockView.frame.size.height - self.progressView.frame.size.height - 40)/2 - 100,
                                                                      self.progressView.frame.size.width + 40,
                                                                      self.progressView.frame.size.height + 80)];
    backgroundView.backgroundColor = [UIColor colorWithWhite:8.0 alpha:0.9f];
    backgroundView.layer.cornerRadius = 5;
    backgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
    backgroundView.layer.shadowRadius = 1.0f;
    backgroundView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    backgroundView.layer.shadowOpacity = 0.25f;
    
    CGRect frame = _progressView.frame;
    frame.origin.x = 20;
    frame.origin.y = 60;
    _progressView.frame = frame;
    
    UILabel *refreshLabel = [[UILabel alloc] init];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:10.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.frame = CGRectMake(0, 0, backgroundView.frame.size.width, backgroundView.frame.size.height);
    refreshLabel.textColor = [UIColor blackColor];
    refreshLabel.text = NSLocalizedString(@"Loading...",nil);
    
    [backgroundView addSubview:refreshLabel];
    [backgroundView addSubview:_progressView];
    [blockView addSubview:backgroundView];
    [self.view addSubview:blockView];
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                             @"addPicture",@"command",
                                             UIImageJPEGRepresentation(storyItem.imageWithText,70),@"file",
                                             _IdStory, @"IdStory",
                                             self, @"progressView",
                                             nil]
                               onCompletion:^(NSDictionary *json) {
                                   [blockView removeFromSuperview];
                                   //completion
                                   if (![json objectForKey:@"error"]) {
                                       
                                       //success
                                       pictureAdded = true;
                                       [self install];
                                       
                                   } else {
                                       //error, check for expired session and if so - authorize the user
                                       //error
                                       NSString* errorcode = [[NSString alloc] initWithString:[json objectForKey:@"error"]];
                                       if([errorcode isEqualToString:@"0007"]){
                                           [UIAlertView error:NSLocalizedString(@"Authorization required. Please login.",nil)];
                                       }
                                       else if([errorcode isEqualToString:@"0008"]){
                                           [UIAlertView error:NSLocalizedString(@"Sorry! An error occured while uploading. Please try again.", nil)];
                                       }
                                       else if([errorcode isEqualToString:@"0009"]){
                                           [UIAlertView error:NSLocalizedString(@"Sorry! There seems to be a problem connecting to our database. Please try again later.", nil)];
                                       }
                                       else if([errorcode isEqualToString:@"0014"]){
                                           [UIAlertView error:NSLocalizedString(@"Sorry! This Tale is already closed.", nil)];
                                           self.contributButton.enabled = NO;
                                       }
                                   }

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
    pageContentViewController.contributer = self.contributer;
    pageContentViewController.storyItems = _storyItems;
    pageContentViewController.pageIndex = index;
    pageContentViewController.pageNumberString = [NSString stringWithFormat:@"%d/%ld",(int)index +1,(long)pagecount];
    
    NSDictionary *storyItem = _storyItems[0];
    
    self.title = [storyItem objectForKey:@"titel"];
    
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
    
    NSDictionary *storyItem = _storyItems[0];
    NSNumber *storyId = [storyItem objectForKey:@"IdStory"];
    
    [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                            @"like",@"command",
                            storyId, @"IdStory",
                            nil]
              onCompletion:^(NSDictionary *json) {
                  if ([json objectForKey:@"error"]==nil) {
                      //success
                      self.likeButton.enabled = NO;
                      [self install];
                  } else {
                      //error
                      NSString* errorcode = [[NSString alloc] initWithString:[json objectForKey:@"error"]];
                      if([errorcode isEqualToString:@"0007"]){
                          [UIAlertView error:NSLocalizedString(@"Authorization required. Please login.",nil)];
                      }
                      else if([errorcode isEqualToString:@"0010"]){
                          self.likeButton.enabled = NO;
                      }
                      else if([errorcode isEqualToString:@"0011"]){
                          [UIAlertView error:NSLocalizedString(@"Sorry! There seems to be a problem connecting to our database. Please try again later.",nil)];
                      }

                  }
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
