//
//  UIImage+drawText.h
//  StoryStrips
//
//  Created by Chris on 26.02.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (drawText)

-(UIImage*) drawText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point numberOfLines:(NSUInteger)numberOfLines;
-(UIImage*) drawCoverText:(NSString*)text inImage:(UIImage*)image atPoint:(CGPoint)point numberOfLines:(NSUInteger)numberOfLines;

@end
