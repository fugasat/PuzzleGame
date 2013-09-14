//
//  PzViewController.m
//  PuzzleGame
//
//  Created by Satoru Takahashi on 2013/09/14.
//  Copyright (c) 2013年 Satoru Takahashi. All rights reserved.
//

#import "PzViewController.h"
#import "PzShapeView.h"
#import "PzShapeModel.h"

@interface PzViewController ()

@end

@implementation PzViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    int shapeSize = [self view].frame.size.width / SHAPE_MATRIX_WIDTH;
    int originY = [self view].frame.size.height - shapeSize * SHAPE_MATRIX_HEIGHT;

    UIView *playGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, originY,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height)];
    [self.view addSubview:playGroundView];
    
    for (int y = 0; y < SHAPE_MATRIX_HEIGHT; y++) {
        for (int x = 0; x < SHAPE_MATRIX_WIDTH; x++) {
            PzShapeModel *model = [[PzShapeModel alloc] init];
            model.location = CGRectMake(x * shapeSize + shapeSize / 2,
                                        y * shapeSize + shapeSize / 2,
                                        shapeSize,
                                        shapeSize);
            PzShapeView *view = [[PzShapeView alloc] initWithFrame:model.location];
            view.center = model.location.origin;
            int colorType = rand() % 3;
            if (colorType == 0) {
                view.color = [UIColor colorWithRed:1.0 green:0.75 blue:0.5 alpha:1.0];
            } else if (colorType == 1) {
                view.color = [UIColor colorWithRed:0.5 green:1.0 blue:0.75 alpha:1.0];
            } else {
                view.color = [UIColor colorWithRed:0.75 green:0.5 blue:1.0 alpha:1.0];
            }
            view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
            
            model.view = view;
            
            [playGroundView addSubview:model.view];

        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
