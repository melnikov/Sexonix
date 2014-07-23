//
//  PlayerView.m
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "PlayerView.h"

@implementation PlayerView

@synthesize direction = _direction, position = _position, forcedDirection = _forcedDirection;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self commonInitialization];
    }
    return self;
}

-(void)commonInitialization
{
	self.backgroundColor = [UIColor clearColor];
	
	self.forcedDirection = NO;
	
	imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"orangeBall.png"]];
	
	imageView.frame = CGRectMake(-self.frame.size.width / 2, -self.frame.size.height / 2, self.frame.size.width * 2, self.frame.size.height * 2);
	
	[self addSubview:imageView];
}

-(void)move
{
	self.position = [self nextMove];
	
	self.frame = CGRectMake(self.position.x * self.frame.size.width, self.position.y * self.frame.size.height,
							self.frame.size.width, self.frame.size.height);
}

-(CGPoint)nextMove
{
	CGPoint pos = self.position;
	
	switch (self.direction)
	{
		case DirectionUp:
			pos.y -= 1;
			break;
			
		case DirectionRight:
			pos.x += 1;
			break;
			
		case DirectionDown:
			pos.y += 1;
			break;
			
		case DirectionLeft:
			pos.x -= 1;
			break;
	}
	
	return pos;
}

-(CGPoint)sidePointIsLeft:(BOOL)isLeft
{
	CGPoint pos = self.position;
	
	switch (self.direction)
	{
		case DirectionUp:
			pos.x += (isLeft ? -1 : 1);
			break;
			
		case DirectionRight:
			pos.y += (isLeft ? -1 : 1);
			break;
			
		case DirectionDown:
			pos.x += (isLeft ? 1 : -1);
			break;
			
		case DirectionLeft:
			pos.y += (isLeft ? 1 : -1);
			break;
	}
	
	return pos;
}

@end
