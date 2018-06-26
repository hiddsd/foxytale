//
//  ExplorPhotoScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ExplorPhotoScreenViewController.h"
#import "ExploraScreenViewController.h"
#import <Social/Social.h>
#import "CustomActionSheet.h"


@interface ExplorPhotoScreenViewController (){
    PFObject *pictureItem;
    PFUser *creator;
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
    [self.imageView.file cancel];
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
    [singleTapGestureRecognizer setDelegate:self];
    [singleTapGestureRecognizer setCancelsTouchesInView:NO];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // Disallow recognition of tap gestures in the segmented control.
    if ( [touch.view isKindOfClass:NSClassFromString(@"UIToolbarButton")] || [touch.view isKindOfClass:[UIToolbar class]] ) {
        return NO;
        
    }
    return YES;
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
    
    pictureItem = _pictureItemArray[_index];
    //load the image
    self.imageView.file = [pictureItem objectForKey:@"image"];
    [self.imageView loadInBackground];
    [self.imageView setBackgroundColor:[UIColor whiteColor]];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    creator = [pictureItem objectForKey:@"user"];
    
    [self.username setTitle:[creator objectForKey:@"username"] forState:UIControlStateNormal];
     //self.username.text = [NSString stringWithFormat:NSLocalizedString(@"By %@",nil), [pictureItem objectForKey:@"username"]];
    
    //Profile Pic
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
    if([creator objectForKey:@"profilepic"] != nil){
        self.profilePicture.file = [creator objectForKey:@"profilepic"];
        [self.profilePicture loadInBackground];
    }
    else{
        self.profilePicture.image = [UIImage imageNamed:@"profilepicph"];
    }
    
    if([self.profilePicture gestureRecognizers] == nil){
        
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapUser)];
        userTap.numberOfTapsRequired = 1;
        [self.profilePicture setUserInteractionEnabled:YES];
        [self.profilePicture addGestureRecognizer:userTap];
    }
}

-(void)tapUser{
    [self performSegueWithIdentifier:@"userProvile" sender:self.username];
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

- (IBAction)showOptions:(id)sender {
    CustomActionSheet* popupQuery;
    if([creator.objectId isEqualToString: [[PFUser currentUser] objectId]]){
        if(_index > 0){
            NSArray* styles = @[@"facebook",@"twitter",@"delete"];
            
            popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"share on facebook",nil),NSLocalizedString(@"share on twitter",nil),NSLocalizedString(@"delete",nil), nil];

        }
        else{
            NSArray* styles = @[@"facebook",@"twitter"];
            
            popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"share on facebook",nil),NSLocalizedString(@"share on twitter",nil),nil];
        }
    }
    else{
        NSArray* styles = @[@"facebook",@"twitter",@"report"];
        
        popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"share on facebook",nil),NSLocalizedString(@"share on twitter",nil),NSLocalizedString(@"report",nil), nil];
    }
    [popupQuery showAlert];
  
}

-(void)modalAlertPressed:(CustomActionSheet *)alert withButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {
        //share on Facebook
        
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://"]]) { //Facebook App is installed
            
            FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
            
            pictureItem = _pictureItemArray[_index];
            PFFile *imageFile = [pictureItem objectForKey:@"image"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:result];
                    photo.image = image;
                    photo.userGenerated = YES;
                    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
                    content.photos = @[photo];
                    content.contentURL = [NSURL URLWithString:(@"https://itunes.apple.com/app/id955868746")];
                    [FBSDKShareDialog showFromViewController:self
                                                 withContent:content
                                                    delegate:self];
                }
            }];
            
        } else if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) { //IOS is hooked with Facebook
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
            
            pictureItem = _pictureItemArray[_index];
            PFFile *imageFile = [pictureItem objectForKey:@"image"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:result];
                    [controller setInitialText:[NSString stringWithFormat:NSLocalizedString(@"posted in Story: %@ on Foxytale", nil), [_story objectForKey:@"title"]]];
                    [controller addImage:image];
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
                }
            }];
            
        } else {
            
            //try true web
            /*
            pictureItem = _pictureItemArray[_index];
            PFFile *imageFile = [pictureItem objectForKey:@"image"];
            NSString *url = imageFile.url;
            
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
            SLComposeViewController *controller = [SLComposeViewController
                                                   composeViewControllerForServiceType:SLServiceTypeTwitter];
            
            pictureItem = _pictureItemArray[_index];
            PFFile *imageFile = [pictureItem objectForKey:@"image"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *result, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:result];
                    [controller setInitialText:[_story objectForKey:@"title"]];
                    [controller addImage:image];
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
                }
            }];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter"
                                                            message:NSLocalizedString(@"Twitter integration is not available.  A Twitter account must be set up on your device.",nil)
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }else if (buttonIndex == 2 && buttonIndex != alert.cancelButtonIndex) { //delete or report
        if([creator.objectId isEqualToString: [[PFUser currentUser] objectId]]){
            //delete
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Delete Image", nil)]
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Are you shour you want to delete this Image?", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"cancel", nil)] otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Ok", nil)], nil];
            alert.tag = 1;
            [alert show];
        }
        else {
            //report
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"Objectionable content", nil)]
                                                            message:[NSString stringWithFormat:NSLocalizedString(@"Report this picture for objectionable content?", nil)] delegate:self cancelButtonTitle:[NSString stringWithFormat:NSLocalizedString(@"cancel", nil)] otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"Ok", nil)], nil];
            alert.tag = 2;
            [alert show];
        }
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


- (void)alertView:(UIAlertView *)alertV didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"DISMISS");
    if(buttonIndex != [alertV cancelButtonIndex] && alertV.tag == 1)
    {
        PFObject *image = _pictureItemArray[_index];
        [image deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSDictionary *itemDetails = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:_index], @"index", nil];
            NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:@"deleteImage" object:self userInfo:itemDetails];
        }];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if(buttonIndex != [alertV cancelButtonIndex] && alertV.tag == 2)
    {
        [pictureItem setObject:@YES forKey:@"flaged"];
        [pictureItem saveInBackground];
               
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"Picture has been reported",nil) delegate:self cancelButtonTitle:NSLocalizedString(@"ok",nil) otherButtonTitles:nil];
        [alert show];
    }
}

@end
