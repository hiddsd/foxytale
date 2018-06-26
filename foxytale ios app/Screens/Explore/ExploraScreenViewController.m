//
//  ExploraScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ExploraScreenViewController.h"
//#import "ThumbnailView.h"
#import "PageStoryViewController.h"
//#import "MSPullToRefreshController.h"
#import "ParseCumunicator.h"
#import <Parse/Parse.h>
#import "ProfileView.h"
#import "UIImage+Resize.h"
#import "UIImage+Utilities.h"
#import "CustomActionSheet.h"

#define MAX_THUMBNNAIL_ITEMS 18

@interface ExploraScreenViewController(private)
-(void)refreshStream;
-(void)showStream:(NSArray*)stream;
@end

@interface ExploraScreenViewController (){
    NSNumber *pageIndex;
    int streamCount;
    NSArray *_stream;
    ProfileView* pView;
    NSData *profileImageData;
    PFFile *profileImageFile;
}

@end

@implementation ExploraScreenViewController

@synthesize profileImageUploadBackgroundTaskId;
@synthesize searchoption, searchTerm;

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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ChangeProfilePicture" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"ChangeProfilePicture"
                                               object:nil];
    
    [self.searchBar setPlaceholder:NSLocalizedString(@"Search #hashtag, @user or tale", nil)];
    
    _ptr = [[CustomPullToRefresh alloc] initWithScrollView:self.listView delegate:self];
    
    if(searchTerm == nil){
        searchTerm=@"";
    }
    if(_option == nil){
        _option = [NSNumber numberWithInt:0];
    }
    if(pageIndex == nil){
        pageIndex = [NSNumber numberWithInt:0];
    }
    
    if(self.searchProgressText == nil){
        self.searchProgressText.text = @"";
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    if(_option){
        _segment.selectedSegmentIndex = [_option intValue];
    }
    if(searchoption == nil){
        searchoption = [NSNumber numberWithInt:0];
    }
    
    if(self.searchBarText != nil && ![self.searchBarText  isEqualToString: @""]){
        self.searchBar.text = self.searchBarText;
    }
    //show the photo stream
    [self refreshStream];
    
}

- (void)receivedNotification:(NSNotification *) notification {

    if([[notification name] isEqualToString:@"ChangeProfilePicture"]){
        NSArray* styles = @[@"cam",@"libary"];
        
        CustomActionSheet *popupQuery = [[CustomActionSheet alloc] initWithTitle:NSLocalizedString(@"Change profile picture",nil) styles:styles delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel",nil) otherButtonTitles:NSLocalizedString(@"take new picture",nil), NSLocalizedString(@"choose from library",nil), nil];
        [popupQuery showAlert];
    }
}

-(void)modalAlertPressed:(CustomActionSheet *)alert withButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
        self.tabBarController.tabBar.hidden = YES;
        
    } else if (buttonIndex == 0) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
        self.tabBarController.tabBar.hidden = YES;
        
    }
}

#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Resize the image to be square (what is shown in the preview)
    
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [[info valueForKey:UIImagePickerControllerOriginalImage]fixOrientation];
    cropRect = [originalImage convertCropRect:cropRect];
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                               bounds:CGSizeMake(100.0f, 100.0f)
                                                 interpolationQuality:kCGInterpolationDefault];
    
    [pView setProfilepicImage:resizedImage];    
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    profileImageData = UIImageJPEGRepresentation(resizedImage, 0.8f);
    
    [self shouldUploadImage];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)shouldUploadImage{
    // Create the PFFiles and store them in properties since we'll need them later
    profileImageFile = [PFFile fileWithData:profileImageData];
    
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.profileImageUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.profileImageUploadBackgroundTaskId];
    }];
    
    [profileImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[UIApplication sharedApplication] endBackgroundTask:self.profileImageUploadBackgroundTaskId];
    }];
    
    [self changeProfilePic];
}

-(void)changeProfilePic{
    PFUser *user = [PFUser currentUser];
    [user setObject:profileImageFile forKey:@"profilepic"];
    
    [user saveInBackground];    
}


-(void)dismissKeyboard {
    if([self.searchBar isFirstResponder]){
        //self.searchBar.text = @"";
        [self.searchBar resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshStream {
    //NSLog(@"PARAMS: option:%@, searchoption:%@, searchTerm:%@, pageIndex:%@", _option, searchoption, searchTerm, pageIndex);
    
    ParseCumunicator *pc = [ParseCumunicator sharedInstance];
    PFQuery *query = [pc queryForExplora:_option searchoption:searchoption searchTerm:searchTerm pageIndex:pageIndex];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects.count == 0 || objects == nil ){

            // Log details of the failure
            //NSLog(@"Error: %@ %@", error, [error userInfo]);
            if([searchoption integerValue] == 1){
                self.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"No tales found for user %@",nil), searchTerm];
            }
            else if([searchoption integerValue] == 2){
                self.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"No tales found for hashtag %@",nil), searchTerm];
            }
            else if([searchoption integerValue] == 3){
                self.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"No tales found with the title %@",nil), searchTerm];
            }
        }
        else{
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            self.searchProgressText.text=@"";
            // Do something with the found objects
        }
        [self showStream:objects];
    }];
}

-(void)showStream:(NSArray*)stream {
    
    _stream = stream;
    
    // 1 remove old photos
    for (UIView* view in _listView.subviews) {
        if([view class] == [ThumbnailView class] || [view class] == [ProfileView class]){
            [view removeFromSuperview];
        }
    }
    
    streamCount = (int)[stream count];
    int max = (streamCount > MAX_THUMBNNAIL_ITEMS) ? MAX_THUMBNNAIL_ITEMS : streamCount;
    
    //ProfileView
    __block int spacing = 0;
    if([searchoption integerValue] == 1){
        //searchUser
        spacing = kprofilehight;
        ParseCumunicator *pc = [ParseCumunicator sharedInstance];
        PFQuery *userQuery = [pc queryForUser:searchTerm];
        [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
            if (!error && object != nil) {
                pView = [[ProfileView alloc] initWithData:(PFUser*)object];
                [_listView addSubview: pView];
            }
        }];
    }
    else if([_option integerValue] == 2){
        //self Profile
        spacing = kprofilehight;
        pView = [[ProfileView alloc] initWithData:[PFUser currentUser]];
        [_listView addSubview: pView];
    }
    
    // 2 add new photo views
    for (int i=0;i<max;i++) {
        PFObject *object = [stream objectAtIndex:i];
        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithIndex:i andData:object andSpacing:spacing];
        thumbnailView.tag = i;
        thumbnailView.delegate = self;
        [_listView addSubview: thumbnailView];
    }
    
    // 3 update scroll list's height
    int listHeight = (int)(([stream count]+3-1)/3 + 1)*(kThumbSide+kPadding) + spacing;
    int width = [UIScreen mainScreen].bounds.size.width;
    [_listView setContentSize:CGSizeMake(width, listHeight)];
    [_listView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
}

-(void)didSelectPhoto:(ThumbnailView*)sender {
    //thumbnail selected - show Story
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInteger:(int)sender.tag],@"IdStory",[NSNumber numberWithBool:sender.openForUser],@"openForUser",nil];
    [self performSegueWithIdentifier:@"ShowStory" sender:dic];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([@"ShowStory" compare: segue.identifier]==NSOrderedSame) {
        PageStoryViewController* pagecontroller = segue.destinationViewController;
        pagecontroller.story = [_stream objectAtIndex:[[sender objectForKey:@"IdStory"] integerValue]];
        pagecontroller.openForUser = [[sender objectForKey:@"openForUser"] boolValue];
    }
}

- (IBAction)changeSeg:(id)sender {
    pageIndex = [NSNumber numberWithInt:0];
    searchTerm = @"";
    self.searchBar.text = @"";
    searchoption = [NSNumber numberWithInt:0];
    if(_segment.selectedSegmentIndex == 0){
        _option = [NSNumber numberWithInt:0];
        [self refreshStream];
    }
    else if(_segment.selectedSegmentIndex == 1){
        _option = [NSNumber numberWithInt:1];
        [self refreshStream];
    }
    else if(_segment.selectedSegmentIndex == 2){
        _option = [NSNumber numberWithInt:2];
        [self refreshStream];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
        [self doSearch];
}

-(void)doSearch{
    //ToDo Peform Search
    NSString *searchString = self.searchBar.text;
    if([searchString isEqualToString:@""] || searchString==nil){
        //search all
        searchTerm = @"";
        searchoption = [NSNumber numberWithInt:0];
        self.searchProgressText.text = @"";
        [self refreshStream];
    }
    else if([searchString characterAtIndex:0]  == '@'){
        //search User
        if(self.segment.selectedSegmentIndex == 2){
            [self.segment setSelectedSegmentIndex:0];
            _option = [NSNumber numberWithInt:0];
        }
        searchTerm = [searchString substringFromIndex:1];
        searchoption = [NSNumber numberWithInt:1];
        self.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"Search for User %@",nil), searchTerm];
        [self refreshStream];
    }
    else if([searchString characterAtIndex:0] == '#'){
        //search Hashtag
        searchTerm = [searchString substringFromIndex:1];
        searchoption = [NSNumber numberWithInt:2];
        self.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"Search for Hashtag %@",nil), searchTerm];
        [self refreshStream];
    }
    else{
        //search Titel
        searchTerm = searchString;
        searchoption = [NSNumber numberWithInt:3];
        self.searchProgressText.text = [NSString stringWithFormat:NSLocalizedString(@"Search for Tale %@",nil), searchTerm];
        [self refreshStream];
    }
}

/*
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self doSearch];
    [self.searchBar resignFirstResponder];
}*/

#pragma mark - CustomPullToRefresh Delegate Methods

- (void) customPullToRefreshShouldRefreshTop:(CustomPullToRefresh *)ptr {
    if([pageIndex integerValue] > 0){
        //privoues page
        int value = [pageIndex intValue];
        pageIndex = [NSNumber numberWithInt:value - 1];
        [self refreshStream];
    }
    else{
        //refresh
        [self refreshStream];
    }
    [_ptr endRefresh];
}

- (void) customPullToRefreshShouldRefreshBottom:(CustomPullToRefresh *)ptr {
    if(streamCount > MAX_THUMBNNAIL_ITEMS){
        //next page
        int value = [pageIndex intValue];
        pageIndex = [NSNumber numberWithInt:value + 1];
        [self refreshStream];
    }
    [_ptr endRefresh];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    UITextField *searchBarTextField = nil;
    for (UIView *subView in self.searchBar.subviews)
    {
        for (UIView *sndSubView in subView.subviews)
        {
            if ([sndSubView isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)sndSubView;
                break;
            }
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
    return YES;
}


- (IBAction)showOptionsMenue:(id)sender {
    [self performSegueWithIdentifier:@"show_optionsmenue" sender:self];
}
@end
