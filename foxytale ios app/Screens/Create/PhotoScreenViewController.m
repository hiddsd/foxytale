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
    NSString *_text;
    BOOL isNew;
    CGRect keyboardFrame;
    UIImageView* addTextView;
    BOOL allowKeyboard;
}

@end

@implementation PhotoScreenViewController


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
    
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [super viewWillDisappear:animated];
    
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.
    
    if([self.photo gestureRecognizers] == nil){
        
        UITapGestureRecognizer *userTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPic)];
        userTap.numberOfTapsRequired = 1;
        [self.photo setUserInteractionEnabled:YES];
        [self.photo addGestureRecognizer:userTap];
    }
    
   
    [self.photo setContentMode:UIViewContentModeScaleAspectFit];
    

    self.photo.layer.borderColor = [UIColor whiteColor].CGColor;
    self.photo.layer.borderWidth = 1.5f;
    self.photo.layer.shadowColor = [UIColor blackColor].CGColor;
    self.photo.layer.shadowRadius = 1.0f;
    self.photo.layer.shadowOffset = CGSizeMake(0.0f, 0.5f);
    self.photo.layer.shadowOpacity = 0.25f;
    
    addTextView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addText"]];
    [addTextView setFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width -10 -addTextView.frame.size.width)/2, ([UIScreen mainScreen].bounds.size.width -10 -addTextView.frame.size.height)/2, addTextView.frame.size.width, addTextView.frame.size.height)];
    
    
    isNew = YES;
    allowKeyboard = NO;
    if(self.storyItem.imageWithText){
        _photo.image = self.storyItem.imageWithText;
        _image = self.storyItem.image;
        [self.photo setBackgroundColor:[UIColor whiteColor]];
        isNew = NO;
        allowKeyboard = YES;
        if([self.storyItem.text isEqualToString:@""]){
            [self.photo addSubview:addTextView];
        }
        else{
            self.photoText.text = self.storyItem.text;
        }
    }
    else{
        [self.photo setContentMode:UIViewContentModeCenter];
    }
    
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

-(void)keyboardOnScreen:(NSNotification *)notification
{
    NSDictionary *info  = notification.userInfo;
    NSValue      *value = info[UIKeyboardFrameEndUserInfoKey];
    
    CGRect rawFrame      = [value CGRectValue];
    keyboardFrame = [self.view convertRect:rawFrame fromView:nil];
    
    NSLog(@"keyboardFrame: %@", NSStringFromCGRect(keyboardFrame));
    [self setTextFieldPosition];
}

-(void)tapPic{
    if([self.photoText isFirstResponder]){
        [self.photoText resignFirstResponder];
        self.photoText.hidden = YES;
    }
    else if(allowKeyboard){
        [self.photoText becomeFirstResponder];
        [addTextView removeFromSuperview];
    }
}

-(void)setTextFieldPosition{
    self.photoText.frame = CGRectMake(0, keyboardFrame.origin.y - 44, self.view.frame.size.width, 44);
    [self.photoText setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    self.photoText.hidden = NO;
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
    UIImage *originalImage = [[info valueForKey:UIImagePickerControllerOriginalImage]fixOrientation];
    cropRect = [originalImage convertCropRect:cropRect];
    UIImage *croppedImage = [originalImage croppedImage:cropRect];
    UIImage *resizedImage = [croppedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                         bounds:CGSizeMake(404.0f, 404.0f)
                                           interpolationQuality:kCGInterpolationHigh];
    //UIImage *resizedImage = [croppedImage makeResizedImage:CGSizeMake(_photo.frame.size.width, _photo.frame.size.height) quality:kCGInterpolationHigh];
    
    //NSLog(@"Size: %f, %f", _photo.frame.size.width, _photo.frame.size.height);
    
    _photo.image = resizedImage;
    _image = resizedImage;
    
    //NSLog(@"Picture Size:%f FRame Size:%f", _image.size.width ,_photo.frame.size.width);
    
    [self.photo setBackgroundColor:[UIColor whiteColor]];
    [self.photo setContentMode:UIViewContentModeScaleAspectFit];
    
    self.addStripButton.enabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.photo addSubview:addTextView];
    allowKeyboard=YES;
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [_toolbar setHidden: YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_toolbar setHidden: NO];
    
    NSString *rawString = [textView text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        [self.photo addSubview: addTextView];
        if(_image){
            _photo.image = _image;
        }
    }
    else{
        
    
        if(_image){
            NSUInteger numberOfLines = [self getNumberOfLines:textView];
            UIImage *img = [[UIImage alloc]init];
            
            NSString *rawString = _photoText.text;
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
            
            img = [img drawText:trimmed inImage:_image atPoint:CGPointMake(0, 0) numberOfLines:numberOfLines];
            //COVER TEST
            //img = [img drawCoverText:_photoText.text inImage:_image atPoint:CGPointMake(0,0) numberOfLines:numberOfLines];
            _photo.image = img;
        }
    }
}
 
- (BOOL)textViewShoudReturn:(UITextView *)textView
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    BOOL shouldChangeText = YES;
    
    if ([text isEqualToString:@"\n"]) {
        // Find the next entry field
        [textView resignFirstResponder];
        shouldChangeText = NO;
        self.photoText.hidden = YES;
    }
    return shouldChangeText;
}


@end
