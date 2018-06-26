//
//  CustomFlowLayout.m
//  StoryStrips
//
//  Created by Chris on 04.04.14.
//  Copyright (c) 2014 Appterprise. All rights reserved.
//

#import "CustomFlowLayout.h"

@implementation CustomFlowLayout

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    for(int i = 0; i < [answer count]; ++i) {
        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
        NSInteger maximumSpacing = 2;
        float cellSize = (self.collectionView.frame.size.width - maximumSpacing - 20) / 2;
        
        if(i == 0){
            CGRect frame = (CGRect){
                .origin.x = 0 + 10,
                .origin.y = 0,
                .size.width = cellSize,
                .size.height = cellSize
            };
            currentLayoutAttributes.frame = frame;
        }
        
        else if(i == 1){
            CGRect frame = (CGRect){
                .origin.x = cellSize + maximumSpacing + 10,
                .origin.y = 0,
                .size.width = cellSize,
                .size.height = cellSize
            };
            currentLayoutAttributes.frame = frame;
        }
        
        else if(i == 2){
            CGRect frame = (CGRect){
                .origin.x = 0 + 10,
                .origin.y = cellSize + maximumSpacing,
                .size.width = cellSize,
                .size.height = cellSize
            };
            currentLayoutAttributes.frame = frame;
        }
        
        else if(i == 3){
            CGRect frame = (CGRect){
                .origin.x = cellSize + maximumSpacing + 10,
                .origin.y = cellSize + maximumSpacing,
                .size.width = cellSize,
                .size.height = cellSize
            };
            currentLayoutAttributes.frame = frame;
        }
    }
    return answer;
}

- (CGSize)collectionViewContentSize{
    return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.height);
}

@end
