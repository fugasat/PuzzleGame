//
//  SSShapeModel.h
//  ShapeScroll
//
//  Created by Satoru Takahashi on 2013/09/11.
//  Copyright (c) 2013年 Satoru Takahashi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PzShapeModel : NSObject
{
@public
@protected
    UIView* _view;
    CGRect _location;
    CGPoint _move;
    CGPoint _moveRange;
@private
}

@property (strong, nonatomic) UIView* view;
@property (assign, nonatomic) CGRect location;
@property (assign, nonatomic) CGPoint move;
@property (assign, nonatomic) CGPoint moveRange;


@end
