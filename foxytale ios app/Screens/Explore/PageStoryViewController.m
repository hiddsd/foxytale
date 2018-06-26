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
#import "ParseCumunicator.h"
#import "ScoreCalculater.h"
#import <Social/Social.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "CustomActionSheet.h"




#define PICTURE_LIMIT 100

@interface PageStoryViewController (){
    NSArray *_storyItems;
    NSInteger pagecount;
    BOOL pictureAdded;
    BOOL pictureDeleted;
    PFQuery *query;
    PFFile *photoFile;
    int deleteItemIndex;
}
@end

@implementation PageStoryViewController

@synthesize storyPostBackgroundTaskId;
@synthesize fileUploadBackgroundTaskId;




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
    else if(pictureDeleted){
        //Wenn der index ein vielfaches von 4 ist und kein nächstes bild vorhanden ist, war das Bild das letzte auf der seite
        if(deleteItemIndex  % 4 == 0 && deleteItemIndex == [_storyItems count]){
            deleteItemIndex--;
        }
        
        //Load Storypage the picture is on
        int pageindex = ceil(((float)deleteItemIndex + 1) / ((float) 4)) - 1;
        startingViewController = [self viewControllerAtIndex:pageindex];
    }
    else{
        startingViewController = [self viewControllerAtIndex:0];
    }
    pictureAdded = false;
    pictureDeleted = false;
    
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
    query = [[ParseCumunicator sharedInstance] queryForStoryPage:_story];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        _storyItems = objects;
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GoBackToStory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"GoBackToStory"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StoryItem to contribute" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"StoryItem to contribute"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"deleteImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"deleteImage"
                                               object:nil];
    
    PFQuery *likeQuery = [[ParseCumunicator sharedInstance] queryForUserLike:_story];
    [likeQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
        if (!error) {
            // The count request succeeded. Log the count
            if(count > 0)self.likeButton.enabled = NO;
        } else {
            // The request failed
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
    else if([[notification name] isEqualToString:@"deleteImage"]){
        NSNumber *numindex = [notification.userInfo objectForKey:@"index"];
        deleteItemIndex = [numindex intValue];
        pictureDeleted = true;
        [self install];

    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    [query cancel];
    if([[self.navigationController viewControllers] indexOfObject:self] == NSNotFound){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LeaveStorry"
                                                            object:self
                                                          userInfo:nil];
    }
}

/*
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
}*/

-(void)shoudAddToStory:(StoryItem*)storyItem{
    // Create the PFFile and store it in properties since we'll need it later
    photoFile = [PFFile fileWithData:storyItem.imageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    if (!photoFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"Dismiss",nil];
        [alert show];
        return;
    }
    
    // Check if user is creator
    PFObject *creator = [self.story objectForKey:@"creator"];
    if([creator.objectId isEqualToString: [[PFUser currentUser] objectId]]){
        [self addToStory:1];
    }
    else{
        // Check if User allready contributet to story
        PFQuery *contributeQuery = [[ParseCumunicator sharedInstance] queryForUserContribute:_story];
        [contributeQuery countObjectsInBackgroundWithBlock:^(int count, NSError *error) {
            if (!error) {
                // The count request succeeded. Log the count
                [self addToStory:count];
            } else {
                // The request failed
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Dismiss",nil];
                [alert show];
            }
        }];
    }
}

-(void)addToStory:(int)contribute{
    
    // CalculateScore
    ScoreCalculater *calculator = [ScoreCalculater sharedInstance];
    NSNumber *score = [calculator calculateScore:[_story objectForKey:@"likes"] date:[NSDate date]];
    
    // Update Story object
    [_story setObject:score forKey:@"score"];
    if(contribute == 0){
        NSNumber *count = [NSNumber numberWithInt:[[_story objectForKey:@"contributers"] intValue] + 1];
        [_story setObject:count forKey:@"contributers"];
    }
    
    // Request a background execution task to allow us to finish uploading
    // the story even if the app is sent to the background
    self.storyPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.storyPostBackgroundTaskId];
    }];
    
    [_story saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Create Photo object
            PFObject *photo = [PFObject objectWithClassName:@"Photo"];
            [photo setObject:[PFUser currentUser] forKey:@"user"];
            [photo setObject:photoFile forKey:@"image"];
            [photo setObject:_story forKey:@"story"];
            [photo setObject:@NO forKey:@"flaged"];
            
            NSInteger i = _storyItems.count +1;
            [photo setObject:[NSNumber numberWithInteger:i] forKey:@"number"];
            
            
            // Photos are public, but may only be modified by the user who uploaded them
            PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [photoACL setPublicReadAccess:YES];
            photo.ACL = photoACL;
                
            [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    // Create Activity object
                    PFObject *activity = [PFObject objectWithClassName:@"Activity"];
                    [activity setObject:[PFUser currentUser] forKey:@"fromUser"];
                    [activity setObject:_story forKey:@"toStory"];
                    [activity setObject:@"contribute" forKey:@"type"];
                    [activity saveInBackground];
                    
                    // Send Push Notification
                    PFUser *creator = [self.story objectForKey:@"creator"];
                    if(![creator.objectId isEqualToString: [[PFUser currentUser] objectId]]){
                        
                        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ contributed to your Story",nil), [[PFUser currentUser]username]];
                        [PFCloud callFunctionInBackground:@"sendPushToUser"
                                           withParameters:@{@"recipientId": creator.objectId, @"message": message}
                                                    block:^(NSString *success, NSError *error) {
                                                        if (!error) {
                                                            // Push sent successfully
                                                            NSLog(@"Push success!");
                                                        }
                                                    }];
                    }
                    
                }
                else{
                    // Log details of the failure
                    NSLog(@"Error: %@ %@", error, [error userInfo]);
                }
                pictureAdded = true;
                [self install];
            }];
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.storyPostBackgroundTaskId];
    }];
    
    /*
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
    */
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
        if(pagecount > 1)[self goToLastPage];
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
        if(pagecount > 1)[self goToFirstPage];
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
    
    self.title = [_story objectForKey:@"title"];
    
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
    
    NSNumber *likes = [NSNumber numberWithInt:[[_story objectForKey:@"likes"] intValue] + 1];
    
    // CalculateScore
    ScoreCalculater *calculator = [ScoreCalculater sharedInstance];
    NSNumber *score = [calculator calculateScore:likes date:[_story updatedAt]];
    
    // Update Story object
    [_story setObject:score forKey:@"score"];
    [_story incrementKey:@"likes"];
    
    // Request a background execution task to allow us to finish uploading
    // the story even if the app is sent to the background
    self.storyPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.storyPostBackgroundTaskId];
    }];
    
    [_story saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // Create Activity object
            PFObject *activity = [PFObject objectWithClassName:@"Activity"];
            [activity setObject:[PFUser currentUser] forKey:@"fromUser"];
            [activity setObject:_story forKey:@"toStory"];
            [activity setObject:@"like" forKey:@"type"];
            [activity saveInBackground];
            
            // Send Push Notification
            PFUser *creator = [self.story objectForKey:@"creator"];
            if(![creator.objectId isEqualToString: [[PFUser currentUser] objectId]]){
                
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ liked your Story",nil), [[PFUser currentUser]username]];
                [PFCloud callFunctionInBackground:@"sendPushToUser"
                                   withParameters:@{@"recipientId": creator.objectId, @"message": message}
                                            block:^(NSString *success, NSError *error) {
                                                if (!error) {
                                                    // Push sent successfully
                                                    NSLog(@"Push success!");
                                                }
                                            }];
                
            }
            
            self.likeButton.enabled = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"likeStory"
                                                                object:self
                                                              userInfo:nil];
        } else {
            
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            [FBSDKShareDialog showFromViewController:self
                                         withContent:content
                                            delegate:nil];
           
            
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.storyPostBackgroundTaskId];
    }];
}

- (IBAction)showOptionsMenu:(id)sender {
    
    PFObject *creator = [self.story objectForKey:@"creator"];
    CustomActionSheet *popupQuery;
    
    if([creator.objectId isEqualToString: [[PFUser currentUser] objectId]]){
        
        NSArray* styles = @[@"facebook",@"twitter",@"edite",@"delete"];
        
        popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"share on facebook",nil),NSLocalizedString(@"share on twitter",nil), NSLocalizedString(@"change description",nil),NSLocalizedString(@"delete",nil), nil];
    }
    else{
        
        NSArray* styles = @[@"facebook",@"twitter"];
        
        popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"share on facebook",nil),NSLocalizedString(@"share on twitter",nil), nil];
    }
    [popupQuery showAlert];
}



- (UIImage *)mergeImagesFromArray: (NSArray *)imageArray {
    
    int highMul = 1;
    int widthMul = 1;
    
    if ([imageArray count] == 0) return nil;
    else if ([imageArray count] == 1) return [imageArray firstObject];
    else if ([imageArray count] == 2){
        widthMul = 2;
    }
    else if ([imageArray count] == 3){
        highMul = 2;
        widthMul = 2;
    }
    else if ([imageArray count] == 4){
        highMul = 2;
        widthMul = 2;
    }
    
    CGSize xmax = CGSizeMake(0.0,0.0);;
    for (UIImage *img in imageArray) {
        CGSize x = img.size;
        if(x.width > xmax.width) xmax.width = x.width;
        if(x.height > xmax.height) xmax.height = x.height;
    }
    
    CGSize imageSize = xmax;
    CGSize finalSize = CGSizeMake(imageSize.width * widthMul, imageSize.height * highMul);
    
    UIGraphicsBeginImageContext(finalSize);
    
    CGRect rect = CGRectMake(0, 0, imageSize.width * widthMul, imageSize.height * highMul);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor * bgColor = [UIColor colorWithHue:0 saturation:0 brightness:0.15 alpha:1.0];
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
    
    for (int i = 0; i < imageArray.count; i++) {
        CGFloat x = 0.0;
        CGFloat y = 0.0;

        UIImage *pos = [imageArray objectAtIndex:i];
        if(i==0){
            x = (imageSize.width - pos.size.width)/2;
            y = (imageSize.height - pos.size.height)/2;
        }
        if (i==1){

            x = (imageSize.width - pos.size.width)/2 + imageSize.width;
            y = (imageSize.height - pos.size.height)/2;
        } else if(i==2){
            x = (imageSize.width - pos.size.width)/2;
            y = (imageSize.height - pos.size.height)/2 + imageSize.height;

        } else if(i==3){

            x = (imageSize.width - pos.size.width)/2 + imageSize.width;
            y = (imageSize.height - pos.size.height)/2 + imageSize.height;
        }
        
        
        UIImage *image = imageArray[i];
        [image drawInRect: CGRectMake(x, y,
                                      pos.size.width, pos.size.height)];
        /*
        CGRect rect = CGRectMake(rx, ry, imageSize.width, imageSize.height);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(context, 1.0, 0.5, 1.0, 1.0);
        CGContextStrokeRect(context, rect);*/
    }
    
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return finalImage;
}


typedef void (^loop_completion_handler_t)(id result);
typedef BOOL (^task_completion_t)(PFObject* object, NSData* data, NSError* error);

- (void) forEachObjectInArray:(NSMutableArray*) array
   retrieveDataWithCompletion:(task_completion_t)taskCompletionHandler
                   completionHandler:(loop_completion_handler_t)completionHandler
{
    // first, check termination condition:
    if ([array count] == 0) {
        if (completionHandler) {
            completionHandler(@"Finished");
        }
        return;
    }
    // handle current item:
    PFObject* object = array[0];
    [array removeObjectAtIndex:0];
    PFFile* file = [object objectForKey:@"image"];
    if (file==nil) {
        if (taskCompletionHandler) {
            NSDictionary* userInfo = @{NSLocalizedFailureReasonErrorKey: @"file object is nil"};
            NSError* error = [[NSError alloc] initWithDomain:@"RetrieveObject"
                                                        code:-1
                                                    userInfo:userInfo];
            if (taskCompletionHandler(object, nil, error)) {
                // dispatch asynchronously, thus invoking itself is not a recursion
                dispatch_async(dispatch_get_global_queue(0,0), ^{
                    [self forEachObjectInArray:array
                    retrieveDataWithCompletion:taskCompletionHandler
                             completionHandler:completionHandler];
                });
            }
            else {
                if (completionHandler) {
                    completionHandler(@"Interuppted");
                }
            }
        }
    }
    else {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            BOOL doContinue = YES;
            if (taskCompletionHandler) {
                doContinue = taskCompletionHandler(object, data, error);
            }
            if (doContinue) {
                // invoke itself (note this is not a recursion")
                [self forEachObjectInArray:array
                retrieveDataWithCompletion:taskCompletionHandler
                         completionHandler:completionHandler];
            }
            else {
                if (completionHandler) {
                    completionHandler(@"Interuppted");
                }
            }
        }];
    }
}

-(void)modalAlertPressed:(CustomActionSheet *)alert withButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 0) {

        
        //share on Facebook
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) { //Facebook App is installed
            
            int currentPage = (int)[[self.pageViewController.viewControllers objectAtIndex:0] pageIndex];
            
            int start = currentPage*4;
            int ende = start + 4;
            if(_storyItems.count >= ende)
                ende = ende;
            else ende = (int)_storyItems.count;
            
            NSLog(@"Current Page: %d start: %d ende: %d",currentPage,start,ende);
            
            NSMutableArray *picArray = [[NSMutableArray alloc] initWithCapacity:(ende - start)];
            NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:(ende - start)];
            
            for(int i = start; i < ende; i++){
                PFObject *story = _storyItems[i];
                [dataArray addObject:story];
            }
            
            NSMutableArray* objects = [dataArray mutableCopy];
            
            [self forEachObjectInArray:objects
            retrieveDataWithCompletion:^BOOL(PFObject* object, NSData* data, NSError* error){
                if (error == nil) {
                    [picArray addObject:[UIImage imageWithData:data]];
                    return YES;
                }
                else {
                    NSLog(@"Error %@\nfor PFObject %@ with data: %@", error, object, data);
                    return NO; // stop iteration, optionally continue anyway
                }
            } completionHandler:^(id result){
                
                NSLog(@"Loop finished with result: %@", result);
                UIImage *photoImage = [self mergeImagesFromArray:picArray];
                
                
                
                
                
                
                //Open Graph Story
                /*
                [PFCloud callFunctionInBackground:@"getFacebookAppLink"
                                   withParameters:@{@"title": [_story objectForKey:@"title"], @"applink": [NSString stringWithFormat:@"foxytale://tale/%@", _story.objectId]}
                                            block:^(NSString *success, NSError *error) {
                                                if (!error) {
                                                    // Push sent successfully
                                                    NSLog(@"AppLink success!: %@", success);
                                                }
                                            }];
                
                // Construct an FBSDKSharePhoto
                FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
                photo.image = photoImage;
                // Optionally set user generated to YES only if this image was created by the user
                // You must get approval for this capability in your app's Open Graph configuration
                // photo.userGenerated = YES;
                
                // Create an object
                NSDictionary *properties = @{
                                             @"og:type": @"Tale",
                                             @"og:title": [_story objectForKey:@"title"],
                                             @"og:description": [_story objectForKey:@"description"],
                                             @"og:image:width":  @"808",
                                             @"og:image:height": @"786"
                                             };
                FBSDKShareOpenGraphObject *object = [FBSDKShareOpenGraphObject objectWithProperties:properties];
                
                // Create an action
                FBSDKShareOpenGraphAction *action = [[FBSDKShareOpenGraphAction alloc] init];
                action.actionType = @"share";
                [action setObject:object forKey:@"Tale"];
                
                // Add the photo to the action. Actions
                // can take an array of images.
                [action setArray:@[photo] forKey:@"image"];
                
                // Create the content
                FBSDKShareOpenGraphContent *content = [[FBSDKShareOpenGraphContent alloc] init];
                content.action = action;
                content.previewPropertyName = @"Tale";
                
                [FBSDKShareDialog showFromViewController:self
                                             withContent:content
                                                delegate:self];
                */
                
                FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
                photo.image = photoImage;
                photo.userGenerated = YES;
                FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
                content.photos = @[photo];
                content.contentURL = [NSURL URLWithString:(@"https://itunes.apple.com/app/id955868746")];
                [FBSDKShareDialog showFromViewController:self
                                             withContent:content
                                                delegate:self];
            }];

            
            
        } else if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) { //IOS is hooked with Facebook
            
            
            int currentPage = (int)[[self.pageViewController.viewControllers objectAtIndex:0] pageIndex];
            
            int start = currentPage*4;
            int ende = start + 4;
            if(_storyItems.count >= ende)
                ende = ende;
            else ende = (int)_storyItems.count;
            
            NSLog(@"Current Page: %d start: %d ende: %d",currentPage,start,ende);
            
            NSMutableArray *picArray = [[NSMutableArray alloc] initWithCapacity:(ende - start)];
            NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:(ende - start)];
            
            for(int i = start; i < ende; i++){
                PFObject *story = _storyItems[i];
                [dataArray addObject:story];
            }
            
            NSMutableArray* objects = [dataArray mutableCopy];
            
            [self forEachObjectInArray:objects
            retrieveDataWithCompletion:^BOOL(PFObject* object, NSData* data, NSError* error){
                if (error == nil) {
                    [picArray addObject:[UIImage imageWithData:data]];
                    return YES;
                }
                else {
                    NSLog(@"Error %@\nfor PFObject %@ with data: %@", error, object, data);
                    return NO; // stop iteration, optionally continue anyway
                }
            } completionHandler:^(id result){
                NSLog(@"Loop finished with result: %@", result);
                NSLog(@"pictureArray: %@", picArray);
                SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                UIImage *photoImage = [self mergeImagesFromArray:picArray];
                NSLog(@"Size of my Image => %f, %f ", [photoImage size].width, [photoImage size].height) ;
                
                [controller setInitialText:[NSString stringWithFormat:NSLocalizedString(@"%@ posted on Foxytale", nil), [_story objectForKey:@"title"]]];
                [controller addImage:photoImage];
                [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id955868746"]];
                [controller setCompletionHandler:^(SLComposeViewControllerResult result)
                 {
                     if (result == SLComposeViewControllerResultCancelled)
                     {
                         NSLog(@"The user cancelled.");
                     }
                     else if (result == SLComposeViewControllerResultDone)
                     {
                         NSLog(@"The user posted to Facebook");
                         [self shareSuccessFacebook];
                     }
                 }];
                [self presentViewController:controller animated:YES completion:Nil];
            }];
    
        }  else {
            
            //try true web
            /*PFFile *photo = [_story objectForKey:@"thumbnail"];
            NSString *url = photo.url;
            
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            [content setContentURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id955868746"]];
            content.imageURL = [NSURL URLWithString:url];
            [content setContentTitle:[_story objectForKey:@"title"]];
            if([_story objectForKey:@"description"] != nil){
                [content setContentDescription:[_story objectForKey:@"description"]];
            }
            [FBSDKShareDialog showFromViewController:self
                                         withContent:content
                                            delegate:self];*/
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                            message:NSLocalizedString(@"Facebook integration is not available. A Facebook account must be set up on your device or Facebook App must be instaled.",nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            
        }

        
    } else if(buttonIndex ==1) {
        //share on Twitter
        
        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        {
            int currentPage = (int)[[self.pageViewController.viewControllers objectAtIndex:0] pageIndex];
            
            int start = currentPage*4;
            int ende = start + 4;
            if(_storyItems.count >= ende)
                ende = ende;
            else ende = (int)_storyItems.count;
            
            NSLog(@"Current Page: %d start: %d ende: %d",currentPage,start,ende);
            
            NSMutableArray *picArray = [[NSMutableArray alloc] initWithCapacity:(ende - start)];
            NSMutableArray *dataArray = [[NSMutableArray alloc] initWithCapacity:(ende - start)];
            
            for(int i = start; i < ende; i++){
                PFObject *story = _storyItems[i];
                [dataArray addObject:story];
            }
            
            NSMutableArray* objects = [dataArray mutableCopy];
            
            [self forEachObjectInArray:objects
            retrieveDataWithCompletion:^BOOL(PFObject* object, NSData* data, NSError* error){
                if (error == nil) {
                    [picArray addObject:[UIImage imageWithData:data]];
                    return YES;
                }
                else {
                    NSLog(@"Error %@\nfor PFObject %@ with data: %@", error, object, data);
                    return NO; // stop iteration, optionally continue anyway
                }
            } completionHandler:^(id result){
                NSLog(@"Loop finished with result: %@", result);
                NSLog(@"pictureArray: %@", picArray);
                UIImage *photoImage = [self mergeImagesFromArray:picArray];
                
                SLComposeViewController *controller = [SLComposeViewController
                                                       composeViewControllerForServiceType:SLServiceTypeTwitter];
                [controller setInitialText:[_story objectForKey:@"title"]];
                [controller addImage:photoImage];
                [controller addURL:[NSURL URLWithString:@"https://itunes.apple.com/app/id955868746"]];
                [controller setCompletionHandler:^(SLComposeViewControllerResult result)
                 {
                     if (result == SLComposeViewControllerResultCancelled)
                     {
                         NSLog(@"The user cancelled.");
                     }
                     else if (result == SLComposeViewControllerResultDone)
                     {
                         NSLog(@"The user posted to Twitter");
                         [self shareSuccessTwitter];
                     }
                 }];
                [self presentViewController:controller animated:YES completion:nil];
                
            }];

        } else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                            message:NSLocalizedString(@"Twitter integration is not available.  A Twitter account must be set up on your device.",nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }else if (buttonIndex == 2) {
        //change description
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditDescription"
                                                            object:self
                                                          userInfo:nil];
        
    } else if (buttonIndex == 3 && buttonIndex != alert.cancelButtonIndex) {
        //delete
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete Tale", nil)]
                                                        message:[NSString stringWithFormat:NSLocalizedString(@"Are you shour you want to delete your Tale?", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"cancel", nil)] otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Ok", nil)], nil];
        alert.tag = 1;
        [alert show];
    }
}

-(void)shareSuccessFacebook {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Facebook"
                                                    message:NSLocalizedString(@"successfully postet on your wall",nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)shareSuccessTwitter {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                    message:NSLocalizedString(@"tweeting successfully",nil)
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults :(NSDictionary*)results {
    NSLog(@"FB: SHARE RESULTS=%@\n",[results debugDescription]);
    if([results objectForKey:@"postId"] != nil)[self shareSuccessFacebook];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"FB: ERROR=%@\n",[error debugDescription]);
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"FB: CANCELED SHARER=%@\n",[sharer debugDescription]);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"contribute_to_story" compare: segue.identifier]==NSOrderedSame) {
        
        PhotoScreenViewController *photoScreenViewController = (PhotoScreenViewController *)segue.destinationViewController;
        
        photoScreenViewController.contributeToStory = YES;
    }
}


- (void)alertView:(UIAlertView *)alertV didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex != [alertV cancelButtonIndex] && alertV.tag == 1)
    {
        [_story deleteInBackground];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
