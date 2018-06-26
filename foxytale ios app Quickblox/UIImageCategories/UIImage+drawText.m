//
//  UIImage+drawText.m
//  StoryStrips
//
//  Created by Chris on 26.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "UIImage+drawText.h"

@implementation UIImage (drawText)

-(UIImage*) drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point numberOfLines:(NSUInteger)numberOfLines
{
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(image.size,NO,0.0);
    else
        UIGraphicsBeginImageContext(image.size);
    
    UIFont *font = [UIFont boldSystemFontOfSize:14]; //font size
    
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)]; //Zeichenfläche
    
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil];
    
    [[UIColor colorWithWhite:0.0 alpha:0.5] set]; //Block color
    
    int coordinateY = image.size.height-([text sizeWithAttributes:attributes].height * numberOfLines); //Y coordinate festlegen
    
    CGContextFillRect(UIGraphicsGetCurrentContext(),
                      CGRectMake(0, coordinateY - 10,
                                 image.size.width, coordinateY - 10)); //Rechteck zeichnen
    
    //Text Eigenschaften festlegen
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes2 = [[NSDictionary alloc] initWithObjectsAndKeys: font,NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName, textStyle,NSParagraphStyleAttributeName, nil];
    
    CGRect rect = CGRectMake(point.x + 5, coordinateY - 5, image.size.width, image.size.height); //Text Zeichen in dieser Fläche
    
    
    [text drawInRect:CGRectIntegral(rect) withAttributes:attributes2]; //Text zeichnen
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

-(UIImage*) drawCoverText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point numberOfLines:(NSUInteger)numberOfLines
{
    if (UIGraphicsBeginImageContextWithOptions != NULL)
        UIGraphicsBeginImageContextWithOptions(image.size,NO,0.0);
    else
        UIGraphicsBeginImageContext(image.size);
    
    // Draw Shadow
    CGSize myShadowOffset = CGSizeMake(1.5, -1.5);
    CGFloat myColorValues[] = {0/255.0f, 0/255.0f, 0/255.0f, 1.0f};
    
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(myContext);
    
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef myColor = CGColorCreate(myColorSpace, myColorValues);
    CGContextSetShadowWithColor (myContext, myShadowOffset, 0, myColor);
    //------
    
    UIFont *font = [UIFont fontWithName:@"Verdana-Bold" size:30]; //font size
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)]; //Zeichenfläche
    
    NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys: font, NSFontAttributeName, nil];
    
    
    int coordinateY = (image.size.height / 2) - ([text sizeWithAttributes:attributes].height * numberOfLines / 2); //Y coordinate festlegen
    
    //Text Eigenschaften festlegen
    NSMutableParagraphStyle *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle.lineBreakMode = NSLineBreakByWordWrapping;
    textStyle.alignment = NSTextAlignmentCenter;
    
    UIColor * color = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0f];
    
    NSDictionary *attributes2 = [[NSDictionary alloc] initWithObjectsAndKeys: font,NSFontAttributeName, color,NSForegroundColorAttributeName, textStyle,NSParagraphStyleAttributeName, nil];

    
    CGRect rect = CGRectMake(point.x + 5, coordinateY + 5, image.size.width, image.size.height); //Text Zeichen in dieser Fläche
    
    [text drawInRect:CGRectIntegral(rect) withAttributes:attributes2]; //Text zeichnen
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;

}


@end
