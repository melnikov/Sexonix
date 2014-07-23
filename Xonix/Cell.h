//
//  CellView.h
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	CellTypeClosed,
	CellTypeOpened,
	CellTypeTemp,
	CellTypeBorder,
	CellTypeUnknown
} CellType;

@interface Cell : UIView

- (id)initWithPosition:(CGPoint)pos;

@property (nonatomic, readwrite) CGPoint position;

@property (nonatomic, readwrite) int type;

@property (nonatomic, readwrite) int lastType;

@end
