//
//  CellView.m
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "Cell.h"

@implementation Cell

@synthesize type = _type, lastType = _lastType, position = _position;

- (id)initWithPosition:(CGPoint)pos
{
    self = [super init];
    if (self) {
        // Initialization code
		self.position = pos;
		self.type = CellTypeClosed;
    }
    return self;
}

-(id)copy
{
	Cell * view = [[Cell alloc] initWithPosition:self.position];
	view.type = self.type;
	view.lastType = self.lastType;
	
	return view;
}

@end
