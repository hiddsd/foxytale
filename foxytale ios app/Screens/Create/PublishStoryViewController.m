//
//  PublishStoryViewController.m
//  StoryStrips
//
//  Created by Chris on 07.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "PublishStoryViewController.h"
#import "StoryItem.h"
#import "UIImage+drawText.h"
#import "UIImage+Resize.h"
#import "UIAlertView+error.h"
#import "ExploraScreenViewController.h"
#import <Parse/Parse.h>
#import "ScoreCalculater.h"

@interface PublishStoryViewController (){
    NSArray *_options;
    NSString *_text;
    NSMutableArray *hashtags;
    CGFloat animatedDistance;
    NSUInteger _selectedIndex;
    NSData *thumbnailImageData;
    NSMutableArray *storyPictures;
    PFFile *thumbnailFile;
    CGRect keyboardFrame;
}
@end

@implementation PublishStoryViewController
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

@synthesize storyItems = _storyItems;
@synthesize storyTitel = _storyTitel;
@synthesize fileUploadBackgroundTaskId;
@synthesize storyPostBackgroundTaskId;
@synthesize thumbnailUploadBackgroundTaskId;
@synthesize photoPostBackgroundTaskId;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardOnScreen:) name:UIKeyboardDidShowNotification object:nil];
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    _storyDescription.text = NSLocalizedString(@"tale description",nil);
    
    self.coverImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.coverImageView.layer.borderWidth = 1.5f;
    self.coverImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.coverImageView.layer.shadowRadius = 1.0f;
    self.coverImageView.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.coverImageView.layer.shadowOpacity = 0.25f;
    
    _options = @[NSLocalizedString(@"Only Me",nil), NSLocalizedString(@"Friends",nil), NSLocalizedString(@"Everybody",nil)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    
    //generate thumbnail
    UIImage *anImage = [[_storyItems objectAtIndex:0] image];
    anImage = [anImage drawCoverText:_storyTitel inImage:anImage atPoint:CGPointMake(0,0) numberOfLines:1];
    UIImage *thumbnailImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                         bounds:CGSizeMake(242.0f, 242.0f)
                                           interpolationQuality:kCGInterpolationDefault];
    
    self.coverImageView.image = thumbnailImage;
    thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8f);
    
    _selectedIndex = 0;
    
    //start file upload
    [self shouldUploadImage];
}

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    [self setViewPosition];
}

-(void)setViewPosition{
    CGRect textViewRect =
    [self.view.window convertRect:self.storyDescription.bounds fromView:self.storyDescription];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textViewRect.origin.y + 0.5 * textViewRect.size.height;
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
        animatedDistance = floor(keyboardFrame.size.height * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
    cell.textLabel.text = _options[indexPath.row];
    if (indexPath.row == _selectedIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_selectedIndex != NSNotFound) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:
                                 [NSIndexPath indexPathForRow:_selectedIndex inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _selectedIndex = indexPath.row;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
}

- (BOOL)textViewShoudReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger numberOfLines = [self getNumberOfLines:textView];
    if (numberOfLines > 12)
    {
        // roll back
        _storyDescription.text = _text;
    }
    else
    {
        // change accepted
        _text = _storyDescription.text;
    }
}

-(NSUInteger)getNumberOfLines:(UITextView *)textView
{
    NSLayoutManager *layoutManager = [textView layoutManager];
    NSUInteger numberOfLines, index, numberOfGlyphs = [layoutManager numberOfGlyphs];
    NSRange lineRange;
    for (numberOfLines = 0, index = 0; index < numberOfGlyphs; numberOfLines++)
    {
        (void) [layoutManager lineFragmentRectForGlyphAtIndex:index
                                               effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
    }
    return numberOfLines;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([_storyDescription.text  isEqualToString: NSLocalizedString(@"tale description",nil)]){
        _storyDescription.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSError *error = NULL;
    NSRegularExpression *tags = [NSRegularExpression
                                 regularExpressionWithPattern:@"[#]([^, .]+)([, .]|$)"
                                 options:NSRegularExpressionCaseInsensitive
                                 error:&error];
    NSArray *matches = [tags matchesInString:_storyDescription.text options:0 range:NSMakeRange(0, _storyDescription.text.length)];
    
    hashtags = [[NSMutableArray alloc]init];
    
    for (NSTextCheckingResult *match in matches) {
        [hashtags addObject:[_storyDescription.text substringWithRange:[match rangeAtIndex:1]]];
        //NSLog(@"%@", [_storyDescription.text substringWithRange:[match rangeAtIndex:1]]);
    }
    
    NSString *rawString = [textView text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        _storyDescription.text = NSLocalizedString(@"tale description",nil);
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldChangeText = YES;
    
    if ([text isEqualToString:@"\n"]) {
        // Find the next entry field
        [textView resignFirstResponder];
        shouldChangeText = NO;
    }    
    return shouldChangeText;
}

/*
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
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

- (BOOL)shouldUploadImage{
    // Create the PFFiles and store them in properties since we'll need them later
    storyPictures = [[NSMutableArray alloc]init];
    for(StoryItem *storyItem in _storyItems){
        PFFile *photoFile = [PFFile fileWithData:storyItem.imageData];
        [storyPictures addObject:photoFile];
        
    }
    thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    __block int i = 1;
    int count = (int)storyPictures.count;
    for(PFFile *photo in storyPictures){
        [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                if(i == count){
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }
                i++;
            } else {
                if(i == count){
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                }
                i++;
            }
        }];
    }
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.thumbnailUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.thumbnailUploadBackgroundTaskId];
    }];

    [thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [[UIApplication sharedApplication] endBackgroundTask:self.thumbnailUploadBackgroundTaskId];
    }];
    
    
    return YES;
}

/*
- (void)setUpProgressView{
    
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

}
*/

- (IBAction)postStory:(id)sender {
    
    _postButton.enabled = false;
    
    //NSDate *start = [NSDate date];
    
    
    [self.storyDescription resignFirstResponder];
    
    // Trim comment and save it for use later
    NSString *storyDescription = [_storyDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([storyDescription isEqualToString:NSLocalizedString(@"tale description",nil)]){
        storyDescription = @"";
    }
    
    // Make sure there were no errors creating the image files
    if (!storyPictures || !thumbnailFile) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        return;
    }
    
    //CalculateScore
    ScoreCalculater *calculator = [ScoreCalculater sharedInstance];
    NSNumber *score = [calculator calculateScore:[NSNumber numberWithInt:0] date:[NSDate date]];
    
    // Create Story object
    PFObject *story = [PFObject objectWithClassName:@"Story"];
    [story setObject:self.storyTitel forKey:@"title"];
    [story setObject:storyDescription forKey:@"description"];
    [story setObject:thumbnailFile forKey:@"thumbnail"];
    [story setObject:[PFUser currentUser] forKey:@"creator"];
    [story setObject:[NSNumber numberWithInteger:_selectedIndex] forKey:@"open"];
    [story setObject:@0 forKey:@"likes"];
    [story setObject:score forKey:@"score"];
    if(hashtags != nil)[story setObject:hashtags forKey:@"hashtags"];
    [story setObject:@1 forKey:@"contributers"];
    
    // Storys are public, but may only be modified by the user who uploaded them
    PFACL *storyACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [storyACL setPublicReadAccess:YES];
    [storyACL setPublicWriteAccess:YES];
    story.ACL = storyACL;
    
    // Request a background execution task to allow us to finish uploading
    // the story even if the app is sent to the background
    self.storyPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.storyPostBackgroundTaskId];
    }];
    
    [story saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            // Request a background execution task to allow us to finish uploading
            // the photo Objects even if the app is sent to the background
            self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
            }];
            
            // Create Photo objects
            int i = 1;
            __block int finsihedCount = 1;
            int count = (int)storyPictures.count;
            for(PFFile *photoFile in storyPictures){
                PFObject *photo = [PFObject objectWithClassName:@"Photo"];
                [photo setObject:[PFUser currentUser] forKey:@"user"];
                [photo setObject:photoFile forKey:@"image"];
                [photo setObject:story forKey:@"story"];
                [photo setObject:[NSNumber numberWithInt:i] forKey:@"number"];
                [photo setObject:@NO forKey:@"flaged"];
                
                // Photos are public, but may only be modified by the user who uploaded them
                PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
                [photoACL setPublicReadAccess:YES];
                photo.ACL = photoACL;
                
                [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        if(finsihedCount == count){
                            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
                        }
                        finsihedCount++;
                    }
                    else{
                        // Log details of the failure
                        NSLog(@"Error: %@ %@", error, [error userInfo]);
                        if(finsihedCount == count){
                            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
                        }
                        finsihedCount++;
                    }
                }];
                i++;
            }
            
            [self performSegueWithIdentifier:@"publish_succes" sender:nil];
            
            _postButton.enabled = true;
            [[UIApplication sharedApplication] endBackgroundTask:self.storyPostBackgroundTaskId];
            
            //NSDate *methodFinish = [NSDate date];
            //NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];
            
            //NSLog(@"Execution Time: %f", executionTime);
            
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
            _postButton.enabled = true;
            [[UIApplication sharedApplication] endBackgroundTask:self.storyPostBackgroundTaskId];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"publish_succes" compare: segue.identifier]==NSOrderedSame) {
        UINavigationController *navController = (UINavigationController *)[[segue.destinationViewController viewControllers] objectAtIndex:0];
        
        ExploraScreenViewController *explora = (ExploraScreenViewController *)([navController viewControllers][0]);
        explora.option = [NSNumber numberWithInt:2];
    }
}

-(void)dismissKeyboard {
    [self.storyDescription resignFirstResponder];
}

@end
