//
//  StoryScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 25.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "StoryScreenViewController.h"
#import "StoryCell.h"
#import "PhotoScreenViewController.h"
#import "PublishStoryViewController.h"


@interface StoryScreenViewController () <UICollectionViewDataSource> {
    NSMutableArray *_storyItems;
    CGFloat animatedDistance;
}

@end

@implementation StoryScreenViewController
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;


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
    _storyItems = [[NSMutableArray alloc] init];
    StoryItem *storyItem = [[StoryItem alloc] init];
    [_storyItems addObject:storyItem];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"StoryItem added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"StoryItem modifide"
                                               object:nil];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    self.shareStoryButton.enabled = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.collectionView reloadData];
    self.tabBarController.tabBar.hidden = NO;
}

-(void)dismissKeyboard {
    [self.storyTitel resignFirstResponder];
}

- (void)receivedNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"StoryItem added"]) {
        NSDictionary *dic = [notification userInfo];
        [self addToStory:[dic valueForKey:@"storyItem"]];
    }
    if([[notification name] isEqualToString:@"StoryItem modifide"]){
        NSDictionary *dic = [notification userInfo];
        [self modifiStory:[dic valueForKey:@"storyItem"] index:[dic valueForKey:@"index"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)modifiStory:(StoryItem*)storyItem index:(NSNumber*)index {
    [_storyItems replaceObjectAtIndex:[index intValue] withObject:storyItem];
    [self.collectionView reloadData];
}

-(void)addToStory:(StoryItem*)storyItem{
    int count = (int)_storyItems.count;
    if(count < 4){
        int index = 0;
        if(count > 1){
            index = count - 1;
        }
        [_storyItems insertObject:storyItem atIndex:index];
        [self.collectionView reloadData];
    }
    else {
        [_storyItems replaceObjectAtIndex:3 withObject:storyItem];
        NSString *rawString = [self.storyTitel text];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
        if ([trimmed length] != 0) {
            self.shareStoryButton.enabled = YES;
        }
    }
    [self.collectionView reloadData];
}

- (IBAction)shareStory:(id)sender {
    [self performSegueWithIdentifier:@"story_to_publish" sender: self];
}

#pragma mark - Collection View Data Sources

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _storyItems.count;
}

// The cell that is returned must be retrieved from a call to - dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StoryCell *storyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StoryCellID" forIndexPath:indexPath];
    NSArray *storyItemsRow = _storyItems[indexPath.row];
    if([storyItemsRow valueForKey:@"imageWithText"]){
        [storyCell.imageView setImage:[storyItemsRow valueForKey:@"imageWithText"]];
        [storyCell.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [storyCell.imageView setBackgroundColor:[UIColor blackColor]];
        storyCell.touchLabel.hidden = YES;
    }
    else{
        [storyCell.imageView setImage:[UIImage imageNamed:@"addstrip"]];
        [storyCell.imageView setContentMode:UIViewContentModeCenter];
        storyCell.touchLabel.hidden = NO;
    }
    
    //create Shadow
  
    storyCell.layer.masksToBounds = NO;
    storyCell.layer.borderColor = [UIColor whiteColor].CGColor;
    storyCell.layer.borderWidth = 1.5f;
    storyCell.layer.shadowColor = [UIColor blackColor].CGColor;
    storyCell.layer.shadowRadius = 1.0f;
    storyCell.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    storyCell.layer.shadowOpacity = 0.25f;

    return storyCell;
}

#pragma mark - Prepare for Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"add_strip" compare: segue.identifier]==NSOrderedSame) {
        StoryCell *cell = (StoryCell *)sender;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
        PhotoScreenViewController *photoScreenViewController = (PhotoScreenViewController *)segue.destinationViewController;
    
        StoryItem *storyItem = _storyItems[indexPath.row];
        photoScreenViewController.storyItem = storyItem;
        photoScreenViewController.index = indexPath.row;
    }
    
    if ([@"story_to_publish" compare: segue.identifier]==NSOrderedSame) {
        PublishStoryViewController *publishStoryViewController = (PublishStoryViewController *)segue.destinationViewController;
        publishStoryViewController.storyTitel = self.storyTitel.text;
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:_storyItems];
        publishStoryViewController.storyItems = array;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    NSString *rawString = [self.storyTitel text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        self.storyTitel.placeholder = NSLocalizedString(@"Tale title",nil);
        self.shareStoryButton.enabled = NO;
    }
    else if([trimmed length] != 0 && [_storyItems count] == 4){
        self.shareStoryButton.enabled = YES;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > 35) ? NO : YES;
}

@end
