//
//  EnemyView.h
//  Xonix
//
//  Created by admin on 21.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "PlayerView.h"

typedef enum
{
	EnemyTypeRegular,
	EnemyTypeScore,
	EnemyTypeFreeze,
	EnemyTypeLife
}
EnemyType;

@interface EnemyView : PlayerView

@property (nonatomic, readwrite) EnemyType type;

-(void)changeDirectionIsHorizontal:(BOOL)isHorizontal;

-(void)freeze;

-(void)killWithCompletionHandler:(void (^)())handler;

@end
