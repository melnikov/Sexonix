//
//  CellView.m
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "CellView.h"

@implementation CellView

@synthesize type = _type, lastType = _lastType;

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
	self.type = CellTypeClosed;
	
	//self.image = [UIImage imageNamed:@"seamlesstexture_darklights.jpg"];
}

-(void)setType:(int)type
{
	_type = type;
	
	if(type == CellTypeBorder)
	{
		self.backgroundColor = [UIColor blueColor];
	}
	else if(type == CellTypeClosed)
	{
		self.backgroundColor = [UIColor blackColor];
	}
	else if(type == CellTypeOpened)
	{
		self.backgroundColor = [UIColor clearColor];
	}
	else if(type == CellTypeTemp)
	{
		self.backgroundColor = [UIColor yellowColor];
	}
}

-(id)copy
{
	CellView * view = [[CellView alloc] initWithFrame:self.frame];
	view.type = self.type;
	view.lastType = self.lastType;
	
	return view;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
