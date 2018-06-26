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
    BOOL storyfull;
}
@end

@implementation StoryScreenViewController


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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StoryItem added" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedNotification:)
                                                 name:@"StoryItem added"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"StoryItem modifide" object:nil];
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
    if([self.storyTitel isFirstResponder])
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
        storyfull = false;
        int index = 0;
        if(count > 1){
            index = count - 1;
        }
        [_storyItems insertObject:storyItem atIndex:index];
        //[self.collectionView reloadData];
    }
    else {
        [_storyItems replaceObjectAtIndex:3 withObject:storyItem];
        storyfull = true;
    }
    NSString *rawString = [self.storyTitel text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] != 0) {
        self.shareStoryButton.enabled = YES;
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
    
    CGRect frame = storyCell.frame;
    frame.origin.y = 0;
    frame.origin.x = 0;
    [storyCell setupImageView:frame];
    
    
    
    if([storyItemsRow valueForKey:@"imageWithText"]){
        [storyCell.imageView setImage:[storyItemsRow valueForKey:@"imageWithText"]];
        [storyCell.imageView setBackgroundColor:[UIColor whiteColor]];
        [storyCell.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    else{
        [storyCell.imageView setImage:[UIImage imageNamed:@"addPicturetap"]];
        [storyCell.imageView setBackgroundColor:[UIColor lightGrayColor]];
        [storyCell.imageView setContentMode:UIViewContentModeCenter];
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
    [_storyTitel resignFirstResponder];
    
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
        if(!storyfull){
            [array removeObjectAtIndex:_storyItems.count -1];
        }
        publishStoryViewController.storyItems = array;
    }
}

- (IBAction)textChanged:(id)sender {
    NSString *rawString = [self.storyTitel text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        self.storyTitel.placeholder = NSLocalizedString(@"Tale title",nil);
        self.shareStoryButton.enabled = NO;
    }
    else if([trimmed length] != 0 && [_storyItems count] > 1){
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
