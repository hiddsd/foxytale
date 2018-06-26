//
//  ActionButton.h
//  Foxytale
//
//  Created by Chris on 03.08.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionButton : UIButton

// class method that will be used when allocating button
+ (ActionButton *)buttonWithText:(NSString *)text style:(NSString*)style;

// instance method to set the button label and let the button know if it is a cancel button
- (id)initWithText:(NSString *)text style:(NSString*)style;

@property (nonatomic, retain) UILabel *label;


@end
