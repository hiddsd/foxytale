//
//  PhotoScreenViewController.m
//  StoryStrips
//
//  Created by Chris on 25.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "PhotoScreenViewController.h"
#import "UIImage+Resize.h"
#import "UIImage+drawText.h"
#import "UIImage+Utilities.h"

@interface PhotoScreenViewController (){
    CGFloat animatedDistance;
    NSString *_text;
    BOOL isNew;
}

@end

@implementation PhotoScreenViewController
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
    
    [self.photo setContentMode:UIViewContentModeScaleAspectFit];
    //create Shadow    
    self.photo.layer.borderColor = [UIColor whiteColor].CGColor;
    self.photo.layer.borderWidth = 1.5f;
    self.photo.layer.shadowColor = [UIColor blackColor].CGColor;
    self.photo.layer.shadowRadius = 1.0f;
    self.photo.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.photo.layer.shadowOpacity = 0.25f;   
    
    
    isNew = YES;
    if(self.storyItem.imageWithText){
        _photo.image = self.storyItem.imageWithText;
        [self.photo setBackgroundColor:[UIColor blackColor]];
        isNew = NO;
    }
    if(self.storyItem.image){
        _image = self.storyItem.image;
        isNew = NO;
    }
    if(self.storyItem.text){
        self.photoText.text = self.storyItem.text;
        isNew = NO;
    }
    else self.photoText.text = NSLocalizedString(@"Text strip",nil);
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
    if(isNew)self.addStripButton.enabled = NO;
    
    CGFloat ratio = 1.0;
    NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.photo
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.photo
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:ratio
                                                                    constant:0];
    
    [self.view addConstraint:constraint1];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
}

-(void)dismissKeyboard {
    [self.photoText resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePhoto:(id)sender {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    self.tabBarController.tabBar.hidden = YES;
    
}

- (IBAction)selectPhoto:(id)sender {

    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.allowsEditing = YES;
    [self presentViewController:imagePicker animated:YES completion:nil];
    self.tabBarController.tabBar.hidden = YES;
    
}


- (IBAction)savePicture:(id)sender {
    
    [self.photoText resignFirstResponder];
    StoryItem *newStoryItem = [[StoryItem alloc]init];
    newStoryItem.imageWithText = _photo.image;
    newStoryItem.image = _image;
    newStoryItem.text = self.photoText.text;
    newStoryItem.imageData = UIImageJPEGRepresentation(_photo.image, 0.8f);
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:newStoryItem forKey:@"storyItem"];
    
    if(_contributeToStory){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StoryItem to contribute"
                                                            object:self
                                                          userInfo:dict];
    }
    
    else if(isNew){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StoryItem added"
                                                            object:self
                                                          userInfo:dict];
    }
    else{
        [dict setObject:[NSNumber numberWithInteger:self.index] forKey:@"index"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StoryItem modifide"
                                                            object:self
                                                          userInfo:dict];
    }
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Image picker delegate methdos
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    // Resize the image to be square (what is shown in the preview)
    CGRect cropRect = [[info valueForKey:UIImagePickerControllerCropRect] CGRectValue];
    UIImage *originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    cropRect = [originalImage convertCropRect:cropRect];
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                               bounds:CGSizeMake(_photo.frame.size.width, _photo.frame.size.height)
                                                 interpolationQuality:kCGInterpolationHigh];
    _photo.image = resizedImage;
    _image = resizedImage;
    [self.photo setBackgroundColor:[UIColor blackColor]];
    
    self.addStripButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_toolbar setHidden: YES];
    if([_photoText.text  isEqualToString: NSLocalizedString(@"Text strip",nil)]){
        _photoText.text = @"";
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
    [_toolbar setHidden: NO];
    
    NSString *rawString = [textView text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        _photoText.text = NSLocalizedString(@"Text strip",nil);
        if(_image){
            _photo.image = _image;
        }
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
    
    
    if(![_photoText.text isEqualToString:NSLocalizedString(@"Text strip",nil)]){
        
    
        if(_image){
            NSUInteger numberOfLines = [self getNumberOfLines:textView];
            UIImage *img = [[UIImage alloc]init];
            img = [img drawText:_photoText.text inImage:_image atPoint:CGPointMake(0, 0) numberOfLines:numberOfLines];
            //COVER TEST
            //img = [img drawCoverText:_photoText.text inImage:_image atPoint:CGPointMake(0,0) numberOfLines:numberOfLines];
            _photo.image = img;
            
        }
    }
}

/*
-(IBAction)effect:(id)sender; {
    //ZU TEST ZWECKEN
    
    GPUImageFilterGroup *filter = [[GPUImageFilterGroup alloc] init];
    
    
    GPUImageKuwaharaFilter *cannyFilter = [[GPUImageKuwaharaFilter alloc] init];
    [(GPUImageFilterGroup*)filter addFilter:cannyFilter];
    
    

    
    [(GPUImageFilterGroup *)filter setInitialFilters:[NSArray arrayWithObject:cannyFilter]];
    [(GPUImageFilterGroup *)filter setTerminalFilter:cannyFilter];
    
    self.photo.image = [filter imageByFilteringImage:self.photo.image];

}
*/
 
- (BOOL)textViewShouldReturn:(UITextView *)textView
{
    [textView resignFirstResponder];
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSUInteger numberOfLines = [self getNumberOfLines:textView];
    if (numberOfLines > 2)
    {
        // roll back
        _photoText.text = _text;
    }
    else
    {
        // change accepted
        _text = _photoText.text;
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


@end
