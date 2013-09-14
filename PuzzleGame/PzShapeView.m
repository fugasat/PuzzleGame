//
//  SSShapeView.m
//  ShapeScroll
//
//  Created by Satoru Takahashi on 2013/09/12.
//  Copyright (c) 2013年 Satoru Takahashi. All rights reserved.
//

#import "PzShapeView.h"

@implementation PzShapeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.width;
    CGContextSetFillColorWithColor(c, self.color.CGColor);
    CGContextFillEllipseInRect(c, CGRectMake(0, 0, w, h));
}

@end
