//
//  EnemyView.m
//  Xonix
//
//  Created by admin on 21.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "EnemyView.h"

@interface EnemyView()
{
	CGPoint velocity;
	
	float speed;
}

@end;

@implementation EnemyView

@synthesize type = _type;

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
	if(!imageView)
		imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenBall.png"]];
	
	imageView.frame = CGRectMake(-self.frame.size.width / 2, -self.frame.size.height / 2, self.frame.size.width * 2, self.frame.size.height * 2);
	
	[self addSubview:imageView];
	
	speed = rand() % 5 + 5;
	
	velocity.x = speed / 10 * (random() % 2 * 2 - 1);
	velocity.y = speed / 10 * (random() % 2 * 2 - 1);
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
	
	pos.x += velocity.x;
	pos.y += velocity.y;
	
	return pos;
}

-(void)changeDirectionIsHorizontal:(BOOL)isHorizontal
{
	if(isHorizontal)
	{
		velocity.x = -velocity.x;
	}
	else
	{
		velocity.y = -velocity.y;
	}
}

-(void)setType:(EnemyType)type
{
	_type = type;
	
	switch (type)
	{
		case EnemyTypeFreeze:
			imageView.image = [UIImage imageNamed:@"blueBall.png"];
			break;
			
		case EnemyTypeScore:
			imageView.image = [UIImage imageNamed:@"redBall.png"];
			break;
			
		case EnemyTypeLife:
			imageView.image = [UIImage imageNamed:@"yellowBall.png"];
			break;
			
		case EnemyTypeRegular:
			imageView.image = [UIImage imageNamed:@"greenBall.png"];
			break;
	}
}

-(void)freeze
{
	velocity.x *= 0.25;
	velocity.y *= 0.25;
	
	[self performSelector:@selector(unfreeze) withObject:nil afterDelay:5];
}

-(void)unfreeze
{
	velocity.x = speed / 10 * (velocity.x > 0 ? 1 : -1);
	velocity.y = speed / 10 * (velocity.y > 0 ? 1 : -1);
}

-(void)killWithCompletionHandler:(void (^)())handler;
{
	[UIView animateWithDuration:0.3 animations:^
	{
		self.transform = CGAffineTransformMakeScale(1.5, 1.5);
	}
	completion:^(BOOL finished)
	{
		[UIView animateWithDuration:0.2 animations:^
		{
			self.transform = CGAffineTransformIdentity;
		}
		completion:^(BOOL finished)
		{
			if(handler)
				handler();
		}];
	}];
}

-(void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end
