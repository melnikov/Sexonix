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

@interface CellView : UIView

@property (nonatomic, readwrite) int type;

@property (nonatomic, readwrite) int lastType;

@end
