//
//  SSShapeModel.h
//  ShapeScroll
//
//  Created by Satoru Takahashi on 2013/09/11.
//  Copyright (c) 2013年 Satoru Takahashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PzShapeView.h"

@interface PzShapeModel : NSObject
{
@public
@protected
    PzShapeView* _view;
    CGRect _location;
    CGPoint _offset;
    CGPoint _move;
    CGPoint _moveRange;
    int groupNo;
    int type;
@private
}

@property (strong, nonatomic) PzShapeView* view;
@property (assign, nonatomic) CGRect location;
@property (assign, nonatomic) CGPoint offset;
@property (assign, nonatomic) CGPoint move;
@property (assign, nonatomic) CGPoint moveRange;
@property (assign, nonatomic) int groupNo;
@property (assign, nonatomic) int type;


@end
