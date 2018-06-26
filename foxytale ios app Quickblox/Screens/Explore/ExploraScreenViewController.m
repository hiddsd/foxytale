//
//  ExploraScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 05.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "ExploraScreenViewController.h"
#import "PageStoryViewController.h"
#import "QuickbloxCumunicator.h"


#define MAX_THUMBNNAIL_ITEMS 18

@interface ExploraScreenViewController(private)
-(void)refreshStream;
-(void)showStream:(NSArray*)stream;
@end

@interface ExploraScreenViewController (){
    NSNumber *pageIndex;
    int streamCount;
    NSArray *_stream;
}

@end

@implementation ExploraScreenViewController

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
    
    //show the photo stream
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
    [self refreshStream];
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
    
    [[QuickbloxCumunicator sharedInstance] queryForExplora:_option searchoption:searchoption searchTerm:searchTerm pageIndex:pageIndex onCompletion:^(NSArray *objects) {
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
        if([view class] == [ThumbnailView class]){
            [view removeFromSuperview];
        }
    }
    
    streamCount = (int)[stream count];
    int max = (streamCount > MAX_THUMBNNAIL_ITEMS) ? MAX_THUMBNNAIL_ITEMS : streamCount;
    
    // 2 add new photo views
    for (int i=0;i<max;i++) {
        QBCOCustomObject *customObject = [stream objectAtIndex:i];
        ThumbnailView* thumbnailView = [[ThumbnailView alloc] initWithIndex:i andData:customObject];
        thumbnailView.tag = i;
        thumbnailView.delegate = self;
        [_listView addSubview: thumbnailView];
    }
    // 3 update scroll list's height
    int listHeight = (int)([stream count]/3 + 1)*(kThumbSide+kPadding);
    [_listView setContentSize:CGSizeMake(320, listHeight)];
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
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
    [self.searchBar resignFirstResponder];
}

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


@end
