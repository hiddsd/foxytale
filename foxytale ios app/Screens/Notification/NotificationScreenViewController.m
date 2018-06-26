//
//  NotificationScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 18.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//


#import "NotificationScreenViewController.h"
#import "NotificationCell.h"
#import "PageStoryViewController.h"
#import "ExploraScreenViewController.h"
#import <Parse/Parse.h>
#import "ParseCumunicator.h"

#define REFRESH_HEADER_HEIGHT 52.0f

@interface NotificationScreenViewController (){
    NSNumber *option;
    NSArray *notificationArray;
    PFObject *storyFromNCell;
    PFUser *userFromNCell;
}

@end

@implementation NotificationScreenViewController

@synthesize textPull, textRelease, textLoading, refreshHeaderView, refreshLabel, refreshArrow, refreshSpinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)getNotifications
{
    ParseCumunicator *pc = [ParseCumunicator sharedInstance];
    PFQuery *query = [pc queryForNotifications:option];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            //NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        notificationArray = objects;
        [self.notificationTabel reloadData];
    }];
}

-(void)viewWillAppear:(BOOL)animated{

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationCellUserSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"NotificationCellUserSelected"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NotificationCellStorySelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"NotificationCellStorySelected"
                                               object:nil];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.notificationTabel.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    option = [NSNumber numberWithInt:0];
    
    [self addPullToRefreshHeader];
    [self setupStrings];
    
    [self getNotifications];
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"NotificationCellUserSelected"]) {
        NSDictionary *dic = [notification userInfo];
        userFromNCell = [dic valueForKey:@"user"];
        [self performSegueWithIdentifier:@"addFriendFromNotification" sender:self];
    }
    else if([[notification name] isEqualToString:@"NotificationCellStorySelected"]){
        NSDictionary *dic = [notification userInfo];
        storyFromNCell = [dic valueForKey:@"story"];
        [self performSegueWithIdentifier:@"showStoryToNotification" sender:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changedSeg:(id)sender {
    if(_segment.selectedSegmentIndex == 0){
        option = [NSNumber numberWithInt:0];
        [self getNotifications];
    }
    else if(_segment.selectedSegmentIndex == 1){
        option = [NSNumber numberWithInt:1];
        [self getNotifications];
    }
    else if(_segment.selectedSegmentIndex == 2){
        option = [NSNumber numberWithInt:2];
        [self getNotifications];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return notificationArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NotificationCell *nCell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    
    PFObject *notification = notificationArray[indexPath.row];
    if([[notification objectForKey:@"type"] isEqualToString:@"contribute"]){
        PFUser *fromUser = [notification objectForKey:@"fromUser"];
        PFObject *story = [notification objectForKey:@"toStory"];
        nCell.story = story;
        nCell.user = fromUser;
        [nCell setAtributetLabel:[NSString stringWithFormat:NSLocalizedString(@"%@ contributet to tale %@",nil), [fromUser objectForKey:@"username"], [story objectForKey:@"title"]]];
    }
    else if([[notification objectForKey:@"type"] isEqualToString:@"like"]){
        PFUser *fromUser = [notification objectForKey:@"fromUser"];
        PFObject *story = [notification objectForKey:@"toStory"];
        nCell.story = story;
        nCell.user = fromUser;
        [nCell setAtributetLabel:[NSString stringWithFormat:NSLocalizedString(@"%@ liked tale %@",nil), [fromUser objectForKey:@"username"], [story objectForKey:@"title"]]];
    }
    else if([[notification objectForKey:@"type"] isEqualToString:@"friend"]){
        PFUser *fromUser = [notification objectForKey:@"fromUser"];
        nCell.user = fromUser;
        nCell.story = nil;
        [nCell setAtributetLabel:[NSString stringWithFormat:NSLocalizedString(@"%@ added you as a friend",nil), [fromUser objectForKey:@"username"]]];
    }
    return nCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"showStoryToNotification" compare: segue.identifier]==NSOrderedSame) {
        PageStoryViewController *pageStoryViewController = (PageStoryViewController *)segue.destinationViewController;
        pageStoryViewController.story = storyFromNCell;
    }
    else if ([@"addFriendFromNotification" compare: segue.identifier]==NSOrderedSame) {
        
        ExploraScreenViewController *explora = (ExploraScreenViewController *)segue.destinationViewController;
        explora.searchTerm = [userFromNCell username];
        explora.searchoption = [NSNumber numberWithInt:1];
        explora.searchBarText = [NSString stringWithFormat:@"@%@", [userFromNCell username]];
    }
}






//_____________________________________

- (void)setupStrings{
    textPull = NSLocalizedString(@"Refresh",nil);
    textRelease = NSLocalizedString(@"Refresh",nil);
    textLoading = NSLocalizedString(@"Loading...",nil);
}

- (void)addPullToRefreshHeader {
    int width = [UIScreen mainScreen].bounds.size.width;
    refreshHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0 - REFRESH_HEADER_HEIGHT - 100 , width, REFRESH_HEADER_HEIGHT + 100)];
    refreshHeaderView.backgroundColor = [UIColor colorWithRed:253/255.0 green:181.0/255.0 blue:63.0/255.0 alpha:1.0f];;
    
    refreshLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0 + 100, width, REFRESH_HEADER_HEIGHT)];
    refreshLabel.backgroundColor = [UIColor clearColor];
    refreshLabel.font = [UIFont boldSystemFontOfSize:12.0];
    refreshLabel.textAlignment = NSTextAlignmentCenter;
    refreshLabel.textColor = [UIColor whiteColor];
    
    refreshArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
    refreshArrow.frame = CGRectMake(floorf((width - refreshArrow.frame.size.width) / 2),
                                    REFRESH_HEADER_HEIGHT - refreshArrow.frame.size.height -5 + 100,
                                    refreshArrow.frame.size.width, refreshArrow.frame.size.height);
    
    
    refreshSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    refreshSpinner.frame = CGRectMake(floorf(floorf(REFRESH_HEADER_HEIGHT - 20) / 2), floorf((REFRESH_HEADER_HEIGHT - 20) / 2), 20, 20);
    refreshSpinner.hidesWhenStopped = YES;
    
    [refreshHeaderView addSubview:refreshLabel];
    [refreshHeaderView addSubview:refreshArrow];
    [refreshHeaderView addSubview:refreshSpinner];
    [self.notificationTabel addSubview:refreshHeaderView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (isLoading) return;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (isLoading) {
        // Update the content inset, good for section headers
        if (scrollView.contentOffset.y > 0)
            self.notificationTabel.contentInset = UIEdgeInsetsZero;
        else if (scrollView.contentOffset.y >= -REFRESH_HEADER_HEIGHT)
            self.notificationTabel.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (isDragging && scrollView.contentOffset.y < 0) {
        // Update the arrow direction and label
        [UIView animateWithDuration:0.25 animations:^{
            if (scrollView.contentOffset.y < -REFRESH_HEADER_HEIGHT) {
                // User is scrolling above the header
                refreshLabel.text = self.textRelease;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI, 0, 0, 1);
            } else {
                // User is scrolling somewhere within the header
                refreshLabel.text = self.textPull;
                [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
            }
        }];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (isLoading) return;
    isDragging = NO;
    if (scrollView.contentOffset.y <= -REFRESH_HEADER_HEIGHT) {
        // Released above the header
        [self startLoading];
    }
}

- (void)startLoading {
    isLoading = YES;
    
    // Show the header
    [UIView animateWithDuration:0.3 animations:^{
        self.notificationTabel.contentInset = UIEdgeInsetsMake(REFRESH_HEADER_HEIGHT, 0, 0, 0);
        refreshLabel.text = self.textLoading;
        refreshArrow.hidden = YES;
        [refreshSpinner startAnimating];
    }];
    
    // Refresh action!
    [self refresh];
}

- (void)stopLoading {
    isLoading = NO;
    
    // Hide the header
    [UIView animateWithDuration:0.3 animations:^{
        self.notificationTabel.contentInset = UIEdgeInsetsZero;
        [refreshArrow layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    }
                     completion:^(BOOL finished) {
                         [self performSelector:@selector(stopLoadingComplete)];
                     }];
}

- (void)stopLoadingComplete {
    // Reset the header
    refreshLabel.text = self.textPull;
    refreshArrow.hidden = NO;
    [refreshSpinner stopAnimating];
}

- (void)refresh {
    // This is just a demo. Override this method with your custom reload action.
    // Don't forget to call stopLoading at the end.
    [self getNotifications];
    [self.notificationTabel reloadData];
    [self stopLoading];
}


@end
