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
#import "ScoreCalculater.h"


@interface PublishStoryViewController (){
    NSArray *_options;
    NSString *_text;
    NSMutableArray *hashtags;
    CGFloat animatedDistance;
    NSUInteger _selectedIndex;
    NSData *thumbnailImageData;
    NSMutableArray *storyPictures;
    QBCOFile *thumbnailFile;
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
                                                            bounds:CGSizeMake(120.0f, 120.0f)
                                              interpolationQuality:kCGInterpolationDefault];
    
    self.coverImageView.image = thumbnailImage;
    thumbnailImageData = UIImageJPEGRepresentation(thumbnailImage, 0.8f);
    
    _selectedIndex = 0;
    
    //start file upload
    [self shouldUploadImage];
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

- (BOOL)shouldUploadImage{
    // Create the QBCOFiles and store them in properties since we'll need them later
    storyPictures = [[NSMutableArray alloc]init];
    for(StoryItem *storyItem in _storyItems){
        QBCOFile *file = [QBCOFile file];
        file.name = self.storyTitel;
        file.contentType = @"image/png";
        file.data = storyItem.imageData;
        [storyPictures addObject:file];
        
    }
    QBCOFile *file = [QBCOFile file];
    file.name = self.storyTitel;
    file.contentType = @"image/png";
    file.data = thumbnailImageData;
    thumbnailFile = file;

    return YES;
}

- (IBAction)postStory:(id)sender {
    
    NSDate *start = [NSDate date];
    
    [self.storyDescription resignFirstResponder];
    // Trim comment and save it for use later
    NSString *storyDescription = [_storyDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if([storyDescription isEqualToString:NSLocalizedString(@"tale description",nil)]){
        storyDescription = @"";
    }
    
    //CalculateScore
    ScoreCalculater *calculator = [ScoreCalculater sharedInstance];
    NSNumber *score = [calculator calculateScore:[NSNumber numberWithInt:0] date:[NSDate date]];

    // Create Story object
    QBCOCustomObject *storyObject = [QBCOCustomObject customObject];
    storyObject.className = @"Story";
    (storyObject.fields)[@"title"] = self.storyTitel;
    (storyObject.fields)[@"description"] = storyDescription;
    (storyObject.fields)[@"open"] = [NSNumber numberWithInteger:_selectedIndex];
    (storyObject.fields)[@"likes"] = @0;
    (storyObject.fields)[@"score"] = score;
    if(hashtags != nil)(storyObject.fields)[@"hashtags"] = hashtags;
    (storyObject.fields)[@"contributers"] = @1;
    // permissions
    QBCOPermissions *permissions = [QBCOPermissions permissions];
    // READ
    permissions.readAccess = QBCOPermissionsAccessOpen;
    // UPDATE
    permissions.updateAccess = QBCOPermissionsAccessOpen;
    // DELETE
    permissions.deleteAccess = QBCOPermissionsAccessOwner;
    storyObject.permissions = permissions;
    
    [QBRequest createObject:storyObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        // Upload thumbnailfile to QuickBlox server
        [QBRequest uploadFile:thumbnailFile className:@"Story" objectID:object.ID fileFieldName:@"thumbnail" successBlock:^(QBResponse *response, QBCOFileUploadInfo *inf) {
            // uploaded
        } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
            // handle progress
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
        //Create Photo Objects
        for(QBCOFile *photoFile in storyPictures){
            
            //Create Photo object
            QBCOCustomObject *photoObject = [QBCOCustomObject customObject];
            photoObject.className = @"Photo";
            (photoObject.fields)[@"_parent_id"] = object.ID;
            
            [QBRequest createObject:photoObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                    
                // Upload file to QuickBlox server
                [QBRequest uploadFile:photoFile className:@"Photo" objectID:object.ID fileFieldName:@"image" successBlock:^(QBResponse *response, QBCOFileUploadInfo *inf) {
                    // uploaded
                } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                    // handle progress
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
            } errorBlock:^(QBResponse *response) {
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
        }
        
        [self performSegueWithIdentifier:@"publish_succes" sender:nil];
        
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:start];

        NSLog(@"##################################################Execution Time: %f ###################################################", executionTime);
        
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Response error: %@", [response.error description]);
        
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
