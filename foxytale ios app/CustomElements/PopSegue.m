//
//  PopSegue.m
//  Foxytale
//
//  Created by Chris on 27.08.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "PopSegue.h"
#import "ExploraScreenViewController.h"

@implementation PopSegue

-(void)perform{
    
    ExploraScreenViewController *destinationController = (ExploraScreenViewController*)[self destinationViewController];
    
    [destinationController.navigationController popViewControllerAnimated:NO];
    [destinationController.navigationController popViewControllerAnimated:NO];
}

@end
