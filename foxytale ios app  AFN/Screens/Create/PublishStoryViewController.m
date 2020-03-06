//
//  PublishStoryViewController.m
//  StoryStrips
//
//  Created by Chris on 07.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "PublishStoryViewController.h"
#import "StoryItem.h"
#import "API.h"
#import "UIImage+drawText.h"
#import "UIAlertView+error.h"
#import "ExploraScreenViewController.h"

@interface PublishStoryViewController (){
    NSArray *_options;
    NSString *_text;
    NSString *_hashtagString;
    CGFloat animatedDistance;
    NSUInteger _selectedIndex;
}

@end

@implementation PublishStoryViewController
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;

@synthesize storyItems = _storyItems;
@synthesize storyTitel = _storyTitel;

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
    
    _storyDescription.text = NSLocalizedString(@"tale description",nil);
    
	// Do any additional setup after loading the view.
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
    UIImage *img = [[UIImage alloc]init];
    UIImage *image = [[_storyItems objectAtIndex:0] image];
    img = [img drawCoverText:_storyTitel inImage:image atPoint:CGPointMake(0,0) numberOfLines:1];
    StoryItem *coverItem = [[StoryItem alloc]init];
    coverItem.imageWithText = img;
    [_storyItems insertObject:coverItem atIndex:0];
    self.coverImageView.image = img;
    
    _selectedIndex = 0;
        
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

- (BOOL)textViewShouldReturn:(UITextView *)textView
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
    
    CGRect textViewRect =
    [self.view.window convertRect:textView.bounds fromView:textView];
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

- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSError *error = NULL;
    NSRegularExpression *tags = [NSRegularExpression
                                 regularExpressionWithPattern:@"[#]([^, .]+)([, .]|$)"
                                 options:NSRegularExpressionCaseInsensitive
                                 error:&error];
    NSArray *hashtags = [tags matchesInString:_storyDescription.text options:0 range:NSMakeRange(0, _storyDescription.text.length)];
    
    NSMutableArray *results = [[NSMutableArray alloc]init];
    
    for (NSTextCheckingResult *match in hashtags) {
        [results addObject:[_storyDescription.text substringWithRange:[match rangeAtIndex:1]]];
        //NSLog(@"%@", [_storyDescription.text substringWithRange:[match rangeAtIndex:1]]);
    }
    _hashtagString = [results componentsJoinedByString:@","];
    //NSLog(@"%@", _hashtagString);
    
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

- (IBAction)postStory:(id)sender {
    [self.storyDescription resignFirstResponder];
    
     if([_storyDescription.text isEqualToString:NSLocalizedString(@"tale description",nil)]){
         _storyDescription.text = @"";
     }
    
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
    
     //upload the image and the title to the web service
     [[API sharedInstance] commandWithParams:[NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"upload",@"command",
     self, @"progressView",
     _storyItems, @"storyItems",
     self.storyTitel, @"title",
     self.storyDescription.text, @"description",
     [_hashtagString lowercaseString], @"hashtags",
     [NSNumber numberWithInteger:_selectedIndex], @"contributers",
     nil]
     onCompletion:^(NSDictionary *json) {
     //[blockView removeFromSuperview];
     //completion
     if (![json objectForKey:@"error"]) {
     
     //success
         [self performSegueWithIdentifier:@"publish_succes" sender:nil];
     
     } else {
     //error, check for expired session and if so - authorize the user
         //error
         NSString* errorcode = [[NSString alloc] initWithString:[json objectForKey:@"error"]];
         if([errorcode isEqualToString:@"0007"]){
             [UIAlertView error:NSLocalizedString(@"Authorization required. Please login.",nil)];
         }
         else if([errorcode isEqualToString:@"0008"]){
             [UIAlertView error:NSLocalizedString(@"Sorry! An error occured while uploading. Please try again.",nil)];
         }
         else if([errorcode isEqualToString:@"0009"]){
             [UIAlertView error:NSLocalizedString(@"Sorry! There seems to be a problem connecting to our database. Please try again later.",nil)];
         }         
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
