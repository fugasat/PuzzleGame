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

const int CONTROL_MODE_NONE = 0;
const int CONTROL_MODE_MOVE = 1;
const int CONTROL_MODE_MOVE_RELEASE = 2;
const int CONTROL_MODE_REMOVE = 3;
const int CONTROL_MODE_DROP = 4;
const int CONTROL_MODE_ADD = 5;

NSTimer *timer;
NSMutableArray *shapeModels;
CGPoint scrollMove;
CGPoint touchLocation;
UIView *playGroundView;
int shapeSize;
int originY;
NSArray *selectedModels = NULL;
int scrollType = 0;
int controlMode;

# pragma mark UI delegate

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeLocations];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.0166f target: self
                                           selector:@selector(main:) userInfo: nil
                                            repeats: YES ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark touch delegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (controlMode != CONTROL_MODE_NONE) {
        return;
    }
    controlMode = CONTROL_MODE_MOVE;
    [self scrollMoveReset];
    touchLocation = [[touches anyObject] locationInView:self.view];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (controlMode != CONTROL_MODE_MOVE) {
        return;
    }

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
    [self touchesFinnaly:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesFinnaly:touches withEvent:event];
}

- (void)touchesFinnaly:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (controlMode != CONTROL_MODE_MOVE) {
        return;
    }
    
    [self scrollMoveReset];
    controlMode = CONTROL_MODE_MOVE_RELEASE;
    
}

# pragma mark UI utility

- (CGSize)screenSize
{
    return CGSizeMake(shapeSize * 6, shapeSize * 5);
}

- (PzShapeModel*)moveModel:(PzShapeModel*)model scrollMove:(CGPoint)scrollMove screenAdjust:(bool)screenAdjust
{
    CGSize screenSize = [self screenSize];
    
    CGRect location = model.location;
    location.origin.x = [self adjustLocation:location.origin.x locationSize:location.size.width
                                        move:model.move.x moveRange:model.moveRange.x
                                  scrollMove:scrollMove.x
                                  screenSize:screenSize.width
                                screenAdjust:screenAdjust];
    location.origin.y = [self adjustLocation:location.origin.y locationSize:location.size.height
                                        move:model.move.y moveRange:model.moveRange.y
                                  scrollMove:scrollMove.y
                                  screenSize:screenSize.height
                                screenAdjust:screenAdjust];
    
    model.view.center = CGPointMake(location.origin.x + model.offset.x, location.origin.y + model.offset.y);
    model.location = location;
    model.move = CGPointMake(0, 0);
    return model;
}

- (float)adjustLocation:(float)locationOrigin locationSize:(float)locationSize
                   move:(float)move moveRange:(float)moveRange
             scrollMove:(float)scrollMove screenSize:(float)screenSize screenAdjust:(bool)screenAdjust
{
    int newLocation = (int)locationOrigin + (int)move + (int)scrollMove;
    if (screenAdjust) {
        int screenFullSize = screenSize;
        int tempOrigin = screenFullSize + newLocation;
        return tempOrigin - (screenFullSize * (int)(tempOrigin / screenFullSize));
    } else {
        return newLocation;
    }
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

- (void)scrollMoveReset
{
    scrollMove.x = 0;
    scrollMove.y = 0;
    selectedModels = NULL;
    scrollType = 0;
}

# pragma mark Timer delegate (Main Loop)

- (void)main:(NSTimer*)timer
{
    CGSize screenSize = [self screenSize];
    switch (controlMode) {
        case CONTROL_MODE_MOVE:
            for (int i = 0; i < [selectedModels count]; i++) {
                PzShapeModel *model = [selectedModels objectAtIndex:i];
                model = [self moveModel:model scrollMove:scrollMove screenAdjust:true];
            }
            break;
            
        case CONTROL_MODE_MOVE_RELEASE:
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
                    model.move = CGPointMake(gap.x, gap.y);
                    model = [self moveModel:model scrollMove:scrollMove screenAdjust:true];
                }
            }
            controlMode = [self groupModels];
            break;
            
        case CONTROL_MODE_REMOVE:
            for (int i = 0; i < [shapeModels count]; i++) {
                PzShapeModel *model = [shapeModels objectAtIndex:i];
                if (model.groupNo < 0) {
                    continue;
                }
                if (model.offset.y < -300) {
                    controlMode = CONTROL_MODE_DROP;
                    [self removeGroupedModels];
                    [self dropModels];
                    break;
                }
                CGRect location = model.location;
                model.offset = CGPointMake(0, model.offset.y - (location.origin.y + 100) / 50 - 3);
                float r,g,b,a;
                [model.view.color getRed:&r green:&g blue:&b alpha:&a];
                model.view.color = [model.view.color colorWithAlphaComponent:a * 0.95];
                
                model = [self moveModel:model scrollMove:scrollMove screenAdjust:false];
                [model.view setNeedsDisplay];
            }
            break;

        case CONTROL_MODE_DROP:
            controlMode = CONTROL_MODE_ADD;
            for (int i = 0; i < [shapeModels count]; i++) {
                PzShapeModel *model = [shapeModels objectAtIndex:i];
                if (model.groupNo >= 0) {
                    continue;
                }
                model.offset = CGPointMake(0, model.offset.y * 0.8);
                if (model.offset.y < -0.1) {
                    controlMode = CONTROL_MODE_DROP;
                }
                model = [self moveModel:model scrollMove:scrollMove screenAdjust:false];
                [model.view setNeedsDisplay];
            }
            if (controlMode == CONTROL_MODE_ADD) {
                [self resetModelsOffset];
                [self addNewModels];
            }
            break;
            
        case CONTROL_MODE_ADD:
            controlMode = CONTROL_MODE_NONE;
            for (int i = 0; i < [shapeModels count]; i++) {
                PzShapeModel *model = [shapeModels objectAtIndex:i];
                model.offset = CGPointMake(0, model.offset.y * 0.8);
                if (model.offset.y < -0.1) {
                    controlMode = CONTROL_MODE_ADD;
                }
                model = [self moveModel:model scrollMove:scrollMove screenAdjust:false];
                [model.view setNeedsDisplay];
            }
            if (controlMode == CONTROL_MODE_NONE) {
                [self resetModelsOffset];
                controlMode = [self groupModels];
            }
            break;
        
        default:
            break;
    }
    scrollMove.x = 0;
    scrollMove.y = 0;
}

# pragma mark Management Models

- (void)initializeLocations
{
    self.view.backgroundColor = [UIColor whiteColor];

    controlMode = CONTROL_MODE_NONE;
    
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
            PzShapeView *view = [[PzShapeView alloc] init];
            view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
            model.view = view;
            [self initializeModel:model matrixX:x matrixY:y];
            
            [playGroundView addSubview:model.view];
            
            [shapeModels addObject:model];
        }
        
    }

    touchLocation.x = -1;
    touchLocation.y = -1;
    
}

- (void)initializeModel:(PzShapeModel*)model matrixX:(int)matrixX matrixY:(int)matrixY
{
    model.groupNo = -1;
    model.location = CGRectMake(matrixX * shapeSize + (int)(shapeSize / 2),
                                matrixY * shapeSize + (int)(shapeSize / 2),
                                shapeSize,
                                shapeSize);
    model.offset = CGPointMake(0, 0);
    model.move = CGPointMake(0, 0);
    model.moveRange = CGPointMake(1, 1);
    model.view.frame = model.location;
    model.view.center = model.location.origin;
    model.type = [self randomTypeToNewModel:NULL];
    [self setModelColor:model];
}

- (void)setModelColor:(PzShapeModel*)model
{
    if (model.type == 0) {
        model.view.color = [UIColor colorWithRed:0.5 green:0.75 blue:1.0 alpha:1.0];
    } else if (model.type == 1) {
        model.view.color = [UIColor colorWithRed:1.0 green:0.75 blue:0.5 alpha:1.0];
    } else if (model.type == 2) {
        model.view.color = [UIColor colorWithRed:0.5 green:1.0 blue:0.75 alpha:1.0];
    } else {
        model.view.color = [UIColor colorWithRed:0.75 green:0.5 blue:1.0 alpha:1.0];
    }
    
}

- (void)removeGroupedModels
{
    CGPoint removedLocation = CGPointMake(-1000, -1000);
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        if (model.groupNo >= 0) {
            CGRect location = model.location;
            location.origin = removedLocation;
            model.view.center = location.origin;
            model.location = location;
        }
    }
}

- (void)dropModels
{
    for (int y = SHAPE_MATRIX_HEIGHT - 1; y >= 0; y--) {
        for (int x = 0; x < SHAPE_MATRIX_WIDTH; x++) {
            PzShapeModel *model = [self searchModels:x matrixY:y];
            if (model == NULL) {
                continue;
            }
            int blankNum = 0;
            for (int sy = y + 1; sy < SHAPE_MATRIX_HEIGHT; sy++) {
                PzShapeModel *smodel = [self searchModels:x matrixY:sy];
                if (smodel == NULL) {
                    blankNum++;
                }
            }
            CGRect location = model.location;
            location.origin.y = (y + blankNum) * shapeSize + (int)(shapeSize / 2);
            model.offset = CGPointMake(0, model.location.origin.y - location.origin.y);
            model.location = location;
        }
    }
}

- (void)resetModelsOffset
{
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        model.offset = CGPointMake(0, 0);
    }
}

- (void)addNewModels
{
    NSMutableArray *newModels = [[NSMutableArray alloc] init];
    for (int i = 0; i < [shapeModels count]; i++) {
        PzShapeModel *model = [shapeModels objectAtIndex:i];
        if (model.groupNo < 0) {
            continue;
        }
        [newModels addObject:model];
        for (int y = SHAPE_MATRIX_HEIGHT - 1; y >= 0; y--) {
            for (int x = 0; x < SHAPE_MATRIX_WIDTH; x++) {
                PzShapeModel *smodel = [self searchModels:x matrixY:y];
                if (smodel == NULL) {
                    [self initializeModel:model matrixX:x matrixY:y];
                    model.offset = CGPointMake(0, -shapeSize * 0.8);
                }
            }
        }
    }
    for (int i = 0; i < [newModels count]; i++) {
        PzShapeModel *model = [newModels objectAtIndex:i];
        CGPoint matrix = [self locationToMatrix:model.location.origin shapeSize:shapeSize];
        NSMutableArray *types = [self enableTypesToNewModel];
        if (matrix.x > 0) {
            PzShapeModel *tmodel = [self searchModels:matrix.x - 1 matrixY:matrix.y];
            if (tmodel != NULL) {
                [self removeTypesFromEnabled:types type:tmodel.type];
            }
        }
        if (matrix.x < SHAPE_MATRIX_WIDTH - 1) {
            PzShapeModel *tmodel = [self searchModels:matrix.x + 1 matrixY:matrix.y];
            if (tmodel != NULL) {
                [self removeTypesFromEnabled:types type:tmodel.type];
            }
        }
        if (matrix.y < SHAPE_MATRIX_HEIGHT - 1) {
            PzShapeModel *tmodel = [self searchModels:matrix.x matrixY:matrix.y + 1];
            if (tmodel != NULL) {
                [self removeTypesFromEnabled:types type:tmodel.type];
            }
        }
        model.type = [self randomTypeToNewModel:types];
        [self setModelColor:model];
        
    }
}

- (void)removeTypesFromEnabled:(NSMutableArray*)types type:(int)type
{
    for (int i = 0; i < [types count]; i++) {
        int etype = [[types objectAtIndex:i] intValue];
        if (type == etype) {
            [types removeObjectAtIndex:i];
            break;
        }
    }
}

- (NSMutableArray*)enableTypesToNewModel
{
    NSMutableArray *types = [[NSMutableArray alloc] init];
    [types addObject:[NSNumber numberWithInt:0]];
    [types addObject:[NSNumber numberWithInt:1]];
    [types addObject:[NSNumber numberWithInt:2]];
    [types addObject:[NSNumber numberWithInt:3]];
    return types;
}

- (int)randomTypeToNewModel:(NSArray*)types
{
    if (types == NULL) {
        types = [self enableTypesToNewModel];
    }
    int count = [types count];
    if (count == 0) {
        return rand() % 4;
    } else {
        int type = rand() % count;
        return [[types objectAtIndex:type] intValue];
    }
}

- (int)groupModels
{
    int newControlMode = CONTROL_MODE_NONE;
    int groupNo = 0;
    for (int y = 0; y < SHAPE_MATRIX_HEIGHT; y++) {
        for (int x = 0; x < SHAPE_MATRIX_WIDTH; x++) {
            int length = [self searchSameGroupModels:groupNo length:0 type:-1 matrixX:x matrixY:y dirX:0 dirY:0];
            //NSLog(@"x=%d,y=%d,l=%d,g=%d",x, y, length, groupNo);
            if (length >= 3) {
                groupNo ++;
                newControlMode = CONTROL_MODE_REMOVE;
            } else {
                [self cancelGroup:groupNo];
            }
        }
    }
    //[self removeGroupedModels];
    return newControlMode;
}

- (int)searchSameGroupModels:(int)groupNo length:(int)length type:(int)type
                     matrixX:(int)matrixX matrixY:(int)matrixY
                        dirX:(int)dirX dirY:(int)dirY
{
    bool searchOrigin = false;
    PzShapeModel *model = [self searchModels:matrixX matrixY:matrixY];
    if (model == NULL) {
        return length;
    }
    if (type < 0) {
        searchOrigin = true;
        type = model.type;
        if (model.groupNo >= 0) {
            return length;
        }
    } else {
        if (type != model.type) {
            return length;
        }
    }
    
    if (model.groupNo < 0) {
        model.groupNo = groupNo;
    }
    
    int newLengthRight = 0;
    int newLengthLeft = 0;
    int newLengthBottom = 0;
    int newLengthTop = 0;
    if (matrixX < SHAPE_MATRIX_WIDTH && (searchOrigin || dirX == 1)) {
        newLengthRight = [self searchSameGroupModels:groupNo length:length type:type
                                             matrixX:matrixX + 1 matrixY:matrixY dirX:1 dirY:0];
    }
    if (matrixX > 0 && (searchOrigin || dirX == -1)) {
        newLengthLeft = [self searchSameGroupModels:groupNo length:length type:type
                                            matrixX:matrixX - 1 matrixY:matrixY dirX:-1 dirY:0];
    }
    if (matrixY < SHAPE_MATRIX_HEIGHT && (searchOrigin || dirY == 1)) {
        newLengthBottom = [self searchSameGroupModels:groupNo length:length type:type
                                              matrixX:matrixX matrixY:matrixY + 1 dirX:0 dirY:1];
    }
    if (matrixY > 0 && (searchOrigin || dirY == -1)) {
        newLengthTop = [self searchSameGroupModels:groupNo length:length type:type
                                           matrixX:matrixX matrixY:matrixY - 1 dirX:0 dirY:-1];
    }
    
    if (searchOrigin) {
        if (newLengthLeft + newLengthRight < 2) {
            newLengthLeft = 0;
            newLengthRight = 0;
        }
        if (newLengthTop + newLengthBottom < 2) {
            newLengthTop = 0;
            newLengthBottom = 0;
        }
        [self cancelGroup:groupNo];
        model.groupNo = groupNo;
        if (newLengthRight > 0) {
            newLengthRight = [self searchSameGroupModels:groupNo length:length type:type
                                                 matrixX:matrixX + 1 matrixY:matrixY dirX:1 dirY:0];
        }
        if (newLengthLeft > 0) {
            newLengthLeft = [self searchSameGroupModels:groupNo length:length type:type
                                                matrixX:matrixX - 1 matrixY:matrixY dirX:-1 dirY:0];
        }
        if (newLengthBottom > 0) {
            newLengthBottom = [self searchSameGroupModels:groupNo length:length type:type
                                                  matrixX:matrixX matrixY:matrixY + 1 dirX:0 dirY:1];
        }
        if (newLengthTop > 0) {
            newLengthTop = [self searchSameGroupModels:groupNo length:length type:type
                                               matrixX:matrixX matrixY:matrixY - 1 dirX:0 dirY:-1];
        }
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
        CGPoint matrix = [self locationToMatrix:model.location.origin shapeSize:shapeSize];
        if (matrixX == matrix.x && matrixY == matrix.y) {
            return model;
        }
    }
    return NULL;
}

- (CGPoint)locationToMatrix:(CGPoint)origin shapeSize:(int)shapeSize
{
    CGPoint matrix = CGPointMake((origin.x - shapeSize / 2) / shapeSize,
                                 (origin.y - shapeSize / 2) / shapeSize);
    return matrix;
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

@end
