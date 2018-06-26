//
//  CustomActionSheet.h
//  Foxytale
//
//  Created by Chris on 03.08.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomActionSheet;

// define the custom actionview delegate
@protocol CustomActionViewDelegate <NSObject>

@optional
// declare the option delegate method which passed in the alert and which button was selected
- (void)modalAlertPressed:(CustomActionSheet *)alert withButtonIndex:(NSInteger)buttonIndex;

@end

@interface CustomActionSheet : UIView

@property (assign) id <CustomActionViewDelegate> delegate;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) float yPosition;
@property (nonatomic, assign) int index;
@property int cancelButtonIndex;

- (void)animateOn;
- (void)animateOff;
- (id)initWithTitle:(NSString *)title styles:(NSArray *)styles delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
- (void)buttonPressedWithIndex:(id)sender;
- (void)showAlert;

@end
