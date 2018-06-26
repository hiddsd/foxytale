//
//  CustomPageViewController.m
//  StoryStrips
//
//  Created by Chris on 11.03.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "CustomPageViewController.h"

@interface CustomPageViewController ()

@end

@implementation CustomPageViewController

static CustomPageViewController *sharedInstance;

+(CustomPageViewController*)getSharedInstance{
    if(!sharedInstance){
        sharedInstance = [[self alloc] init];
        // init your object how you need it
    }
    return sharedInstance;
}

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)disablePaging{
    for (UIGestureRecognizer *gr in [self gestureRecognizers]) {
        [gr setEnabled:NO];
    }
}

-(void)enablePaging{
    for (UIGestureRecognizer *gr in [self gestureRecognizers]) {
        [gr setEnabled:YES];
    }
}

-(void)disableBorderPaging{
    for (UIGestureRecognizer *recognizer in [self gestureRecognizers]) {
        if ([recognizer isKindOfClass:[UITapGestureRecognizer class]]) {
            recognizer.enabled = NO;
        }
    }
}


@end
