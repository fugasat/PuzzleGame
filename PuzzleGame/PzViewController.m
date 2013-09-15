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

NSTimer *timer;
NSMutableArray *shapeModels;
CGPoint scrollMove;
CGPoint touchLocation;
UIView *playGroundView;
int shapeSize;
int originY;
NSArray *selectedModels = NULL;
int scrollType = 0;
bool groupingEnabled = false;

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeLocations];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.0166f target: self
                                           selector:@selector(ticker:) userInfo: nil
                                            repeats: YES ];
}

- (void)initializeLocations
{
    self.view.backgroundColor = [UIColor whiteColor];

    shapeSize = [self view].frame.size.width / SHAPE_MATRIX_WIDTH;
    originY = [self view].frame.size.height - shapeSize * SHAPE_MATRIX_HEIGHT;
    
    playGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, originY,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height - originY)];
    [self.view addSubview:playGroundView];
    
    shapeModels = [[NSMutableArray alloc] init];
    for (int y = 0; y < SHAPE_MATRIX_HEIGHT; y++) {
        for (int x = 0; x < SHAPE_MATRIX_WIDTH; x++) {
            PzShapeModel *model = [[PzShapeModel alloc] init];
            model.groupNo = -1;
            model.location = CGRectMake(x * shapeSize + (int)(shapeSize / 2),
                                        y * shapeSize + (int)(shapeSize / 2),
                                        shapeSize,
                                        shapeSize);
            model.move = CGPointMake(0, 0);
            model.moveRange = CGPointMake(1, 1);
            PzShapeView *view = [[PzShapeView alloc] initWithFrame:model.location];
            view.center = model.location.origin;
            model.type = rand() % 4;
            if (model.type == 0) {
                view.color = [UIColor colorWithRed:0.5 green:0.75 blue:1.0 alpha:1.0];
            } else if (model.type == 1) {
                view.color = [UIColor colorWithRed:1.0 green:0.75 blue:0.5 alpha:1.0];
            } else if (model.type == 2) {
                view.color = [UIColor colorWithRed:0.5 green:1.0 blue:0.75 alpha:1.0];
            } else {
                view.color = [UIColor colorWithRed:0.75 green:0.5 blue:1.0 alpha:1.0];
            }
            view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
            
            model.view = view;
            
            [playGroundView addSubview:model.view];
            
            [shapeModels addObject:model];
        }
        
    }

    touchLocation.x = -1;
    touchLocation.y = -1;
    
}

- (void)ticker:(NSTimer*)timer
{
    if (selectedModels != NULL) {
        for (int i = 0; i < [selectedModels count]; i++) {
            PzShapeModel *model = [selectedModels objectAtIndex:i];
            model = [self moveModel:model scrollMove:scrollMove];
            //[shapeModels replaceObjectAtIndex:i withObject:model];
        }
    } else {
        bool gapOccurred = false;
        CGSize screenSize = [self screenSize];
        for (int i = 0; i < [shapeModels count]; i++) {
            PzShapeModel *model = [shapeModels objectAtIndex:i];
            if (model.groupNo < 0) {
                model.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
            } else {
                model.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.8 alpha:1.0];
            }
            CGRect location = model.location;
            CGPoint gap = CGPointMake(
                                      (int)(screenSize.width + location.origin.x - shapeSize / 2) % shapeSize,
                                      (int)(screenSize.height + location.origin.y - shapeSize / 2) % shapeSize);
            if (gap.x < shapeSize / 2) {
                gap.x = -gap.x;
            } else if (gap.x >= shapeSize / 2) {
                gap.x = shapeSize - gap.x;
            }
            if (gap.y < shapeSize / 2) {
                gap.y = -gap.y;
            } else if (gap.y >= shapeSize / 2) {
                gap.y = shapeSize - gap.y;
            }
            if (gap.x != 0 || gap.y != 0) {
                gapOccurred = true;
                model.move = CGPointMake(gap.x, gap.y);
                model = [self moveModel:model scrollMove:scrollMove];
            }
        }
    }
    scrollMove.x = 0;
    scrollMove.y = 0;
    if (groupingEnabled) {
        [self groupModels];
    }
}

- (CGSize)screenSize
{
    return CGSizeMake(shapeSize * 6, shapeSize * 5);
}

- (PzShapeModel*)moveModel:(PzShapeModel*)model scrollMove:(CGPoint)scrollMove
{
    CGSize screenSize = [self screenSize];
    
    CGRect location = model.location;
    location.origin.x = [self adjustLocation:location.origin.x locationSize:location.size.width
                                        move:model.move.x moveRange:model.moveRange.x
                                  scrollMove:scrollMove.x
                                  screenSize:screenSize.width];
    location.origin.y = [self adjustLocation:location.origin.y locationSize:location.size.height
                                        move:model.move.y moveRange:model.moveRange.y
                                  scrollMove:scrollMove.y
                                  screenSize:screenSize.height];
    
    model.view.center = location.origin;
    model.location = location;
    model.move = CGPointMake(0, 0);
    return model;
}

- (float)adjustLocation:(float)locationOrigin locationSize:(float)locationSize
                   move:(float)move moveRange:(float)moveRange
             scrollMove:(float)scrollMove screenSize:(float)screenSize
{
    int screenFullSize = screenSize + locationSize * 0;
    int tempOrigin = screenFullSize + (int)locationOrigin + ((int)move + (int)scrollMove);
    return tempOrigin - (screenFullSize * (int)(tempOrigin / screenFullSize));
}

- (float)adjustMove:(float)move
{
    if (move > 0 || move < 0) {
        move = move * 0.97;
        if (move > -0.01 && move < 0.01) {
            move = 0;
        }
    }
    return move;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)groupModels
{
    int groupNo = 0;
    for (int y = 0; y < SHAPE_MATRIX_HEIGHT; y++) {
        for (int x = 0; x < SHAPE_MATRIX_WIDTH; x++) {
            int length = [self groupModels:groupNo length:0 type:-1 matrixX:x matrixY:y];
            //NSLog(@"x=%d,y=%d,l=%d,g=%d",x, y, length, groupNo);
            if (length >= 4) {
                groupNo ++;
            } else {
                [self cancelGroup:groupNo];
            }
        }
    }
}

- (int)groupModels:(int)groupNo length:(int)length type:(int)type matrixX:(int)matrixX matrixY:(int)matrixY
{
    bool searchOrigin = false;
    PzShapeModel *model = [self searchModels:matrixX matrixY:matrixY];
    if (model == NULL) {
        return length;
    }
    if (model.groupNo >= 0) {
        return length;
    }
    if (type < 0) {
        searchOrigin = true;
        type = model.type;
    } else {
        if (type != model.type) {
            return length;
        }
    }
    
    model.groupNo = groupNo;
    
    int newLengthRight = 0;
    int newLengthLeft = 0;
    int newLengthBottom = 0;
    int newLengthTop = 0;
    if (matrixX < SHAPE_MATRIX_WIDTH) {
        newLengthRight = [self groupModels:groupNo length:length type:type matrixX:matrixX + 1 matrixY:matrixY];
    }
    if (matrixX > 0) {
        newLengthLeft = [self groupModels:groupNo length:length type:type matrixX:matrixX - 1 matrixY:matrixY];
    }
    if (matrixY < SHAPE_MATRIX_HEIGHT) {
        newLengthBottom = [self groupModels:groupNo length:length type:type matrixX:matrixX matrixY:matrixY + 1];
    }
    if (matrixY > 0) {
        newLengthTop = [self groupModels:groupNo length:length type:type matrixX:matrixX matrixY:matrixY - 1];
    }
    int newLength = 1 + newLengthRight + newLengthLeft + newLengthBottom + newLengthTop;
    return newLength;
}

- (void)cancelGroup:(int)groupNo
{
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        if (model.groupNo == groupNo) {
            model.groupNo = -1;
        }
    }
}

- (void)resetGroup
{
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        model.groupNo = -1;
    }
}

- (PzShapeModel*)searchModels:(int)matrixX matrixY:(int)matrixY
{
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        int modelMatrixX = (model.location.origin.x - shapeSize / 2) / shapeSize;
        int modelMatrixY = (model.location.origin.y - shapeSize / 2) / shapeSize;
        if (matrixX == modelMatrixX && matrixY == modelMatrixY) {
            return model;
        }
    }
    return NULL;
}

- (NSMutableArray*)selectRowModels:(int) touchY
{
    NSMutableArray *selectedModels = [[NSMutableArray alloc] init];
    if (touchY < originY) {
        return selectedModels;
    }
    
    int touchMatrixY = (touchY - originY) / shapeSize;
    
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        int matrixY = (model.location.origin.y - shapeSize / 2) / shapeSize;
        if (touchMatrixY == matrixY) {
            [selectedModels addObject:model];
        }
    }
    return selectedModels;
}

- (NSMutableArray*)selectColumnModels:(int) touchX
{
    NSMutableArray *selectedModels = [[NSMutableArray alloc] init];
    
    int touchMatrixX = touchX / shapeSize;
    
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        int matrixX = (model.location.origin.x - shapeSize / 2) / shapeSize;
        if (touchMatrixX == matrixX) {
            [selectedModels addObject:model];
        }
    }
    return selectedModels;
}

// タッチイベントを取る
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self scrollMoveReset];
    touchLocation = [[touches anyObject] locationInView:self.view];

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint currentLocation = [[touches anyObject] locationInView:self.view];
    CGPoint move = CGPointMake((int)(currentLocation.x - touchLocation.x),
                               (int)(currentLocation.y - touchLocation.y));
    if (scrollType == 0) {
        if (fabs(move.x) > fabs(move.y)) {
            scrollType = 1;
            selectedModels = [self selectRowModels:touchLocation.y];
        } else {
            scrollType = 2;
            selectedModels = [self selectColumnModels:touchLocation.x];
        }
        [self resetGroup];
    }
    if (scrollType == 1) {
        move.y = 0;
    } else {
        move.x = 0;
    }
    scrollMove = move;
    touchLocation = currentLocation;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self scrollMoveReset];
    groupingEnabled = true;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self scrollMoveReset];
    groupingEnabled = true;
}

- (void)scrollMoveReset
{
    scrollMove.x = 0;
    scrollMove.y = 0;
    selectedModels = NULL;
    scrollType = 0;
}

@end
