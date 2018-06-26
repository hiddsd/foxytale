//
//  ActionButton.m
//  Foxytale
//
//  Created by Chris on 03.08.15.
//  Copyright (c) 2015 Appterprise. All rights reserved.
//

#import "ActionButton.h"

@implementation ActionButton

+ (ActionButton *)buttonWithText:(NSString *)text style:(NSString*)style
{
    // return the initialized button
    return [[self alloc] initWithText:text style:(NSString*)style];
}

- (id)initWithText:(NSString *)text style:(NSString*)style
{
    // initialize
    self = [super init];
    if (self != nil) {
        
        // we are only using a single image for the demo, but this project is set up for
        // an image with a highlighted state
        UIImage *mainImage;
        UIImage *tappedImage;
        
        // check if the image is a cancel button, if it is  we will use a special image
        if ([style isEqualToString:@"facebook"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"facebook.png"];
            tappedImage = [UIImage imageNamed:@"facebook.png"];
        } else if ([style isEqualToString:@"twitter"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"twitter.png"];
            tappedImage = [UIImage imageNamed:@"twitter.png"];
        } else if ([style isEqualToString:@"email"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"email.png"];
            tappedImage = [UIImage imageNamed:@"email.png"];
        } else if ([style isEqualToString:@"sms"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"sms.png"];
            tappedImage = [UIImage imageNamed:@"sms.png"];
        } else if ([style isEqualToString:@"whatsapp"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"whatsapp.png"];
            tappedImage = [UIImage imageNamed:@"whatsapp.png"];
        } else if ([style isEqualToString:@"cam"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"newpic.png"];
            tappedImage = [UIImage imageNamed:@"newpic.png"];
        }else if ([style isEqualToString:@"libary"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"libary.png"];
            tappedImage = [UIImage imageNamed:@"libary.png"];
        }else if ([style isEqualToString:@"search"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"search.png"];
            tappedImage = [UIImage imageNamed:@"search.png"];
        }else if ([style isEqualToString:@"edite"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"edit.png"];
            tappedImage = [UIImage imageNamed:@"edit.png"];
        }else if ([style isEqualToString:@"delete"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"delete.png"];
            tappedImage = [UIImage imageNamed:@"delete.png"];
        }else if ([style isEqualToString:@"report"]){ // otherwise the default button image will be a green button
            mainImage = [UIImage imageNamed:@"report.png"];
            tappedImage = [UIImage imageNamed:@"report.png"];
        }


        self.backgroundColor = [UIColor darkGrayColor];
        [self setBackgroundImage:[self imageWithColor:[UIColor darkGrayColor]] forState:UIControlStateNormal];
        [self setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:45/255.0 green:45/255.0 blue:45/255.0 alpha:1.0]] forState:UIControlStateHighlighted];

        
        // create the buttons frame
        CGRect frame;
        frame.size = CGSizeMake([UIScreen mainScreen].bounds.size.width, 40);
        self.frame = frame;
        
        
        // set up button label
        
        _label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _label.backgroundColor = [UIColor clearColor];
        if([style isEqualToString:@"cancel"]){
            _label.textColor = [UIColor colorWithRed:255/255.0 green:153/255.0 blue:0/255.0 alpha:1];
        }
        else {
           _label.textColor = [UIColor whiteColor];
        }
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = text;
        
        
        if(mainImage != nil){
            // set button images
            [self setImage:mainImage forState:UIControlStateNormal];
            [self setImage:tappedImage forState:UIControlStateHighlighted];
            
            [_label sizeToFit];
            frame = _label.frame;
            //frame.size.width = self.frame.size.width ;
            frame.size.height = 19;
            frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
            frame.origin.y = self.frame.size.height/2 - frame.size.height/2;
            _label.frame = CGRectIntegral(frame);

            
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -_label.frame.size.width - 50, 0, 0);
        }
        else {
            [_label sizeToFit];
            frame = _label.frame;
            //frame.size.width = self.frame.size.width ;
            frame.size.height = 19;
            frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
            frame.origin.y = self.frame.size.height/2 - frame.size.height/2;
            _label.frame = CGRectIntegral(frame);
        }
        
        [self addSubview:_label];
        
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



@end
