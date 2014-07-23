//
//  PlayerView.h
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	DirectionUp,
	DirectionRight,
	DirectionDown,
	DirectionLeft
}Direction;

@interface PlayerView : UIImageView
{
	UIImageView * imageView;
}

@property (nonatomic, readwrite) Direction direction;

@property (nonatomic, readwrite) CGPoint position;

@property (nonatomic, readwrite) BOOL forcedDirection;

-(void)move;

-(CGPoint)nextMove;

-(CGPoint)sidePointIsLeft:(BOOL)isLeft;

@end
