//
//  GameViewController.m
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "GameViewController.h"
#import "NSMutableArray+NullInt.h"
#import "CellView.h"
#import "PlayerView.h"

#define FIELD_WIDTH 50

#define FIELD_HEIGHT 80

#define UPDATE_DELAY 0.05

@interface GameViewController ()
{
	IBOutlet UIImageView *imageView;
	
	CGSize cellSize;
	
	int check[FIELD_HEIGHT][FIELD_WIDTH];
	
	CellView * cells[FIELD_HEIGHT][FIELD_WIDTH];
	
	int leftCount;
	
	int rightCount;
	
	PlayerView * player;
}

@property (nonatomic, strong) NSMutableArray * temp;

@end

@implementation GameViewController

@synthesize temp = _temp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	CGSize size = imageView.frame.size;
	
	cellSize = CGSizeMake(size.width / FIELD_WIDTH, size.width / FIELD_WIDTH);
	
	imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, cellSize.height * FIELD_HEIGHT);
	
	self.temp = [[NSMutableArray alloc] initWithCapacity:1];
	
	for(int y = 0; y < FIELD_HEIGHT; y++)
		for (int x = 0; x < FIELD_WIDTH; x++)
		{
			CellView *cell = [[CellView alloc] initWithFrame:CGRectMake(x * cellSize.width, y * cellSize.height, cellSize.width, cellSize.height)];
			
			if(y == 0 || y == FIELD_HEIGHT - 1 || x == 0 || x == FIELD_WIDTH - 1)
			{
				cell.type = CellTypeBorder;
			}
			
			[imageView addSubview:cell];
			
			cells[y][x] = cell;
			
			check[y][x] = cell.type;
		}
	
	player = [[PlayerView alloc] initWithFrame:CGRectMake(0, (FIELD_HEIGHT - 1) * cellSize.height, cellSize.width, cellSize.height)];
	
	player.position = CGPointMake(0, FIELD_HEIGHT - 1);
	
	player.direction = DirectionRight;
	
	[imageView addSubview:player];
	
	UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRecognizer:)];
	swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
	[self.view addGestureRecognizer:swipeGestureRecognizer];
	swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRecognizer:)];
	swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
	[self.view addGestureRecognizer:swipeGestureRecognizer];
	swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRecognizer:)];
	swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	[self.view addGestureRecognizer:swipeGestureRecognizer];
	swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFromRecognizer:)];
	swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	[self.view addGestureRecognizer:swipeGestureRecognizer];
	
	[self performSelector:@selector(update) withObject:nil afterDelay:0];
}

-(void)update
{
	CGPoint nextPoint = [player nextMove];
	
	CellView * nextCell = nil;
	
	if(nextPoint.x >= 0 && nextPoint.y >= 0 && nextPoint.x < FIELD_WIDTH && nextPoint.y < FIELD_HEIGHT)
		nextCell = cells[(int)nextPoint.y][(int)nextPoint.x];
	
	CellView * curCell = cells[(int)player.position.y][(int)player.position.x];
	
	if(curCell.type == CellTypeTemp)
	{
		if(nextCell.type == CellTypeTemp)
		{
			NSLog(@"Game Over");
			
			return;
		}
		else if(nextCell.type == CellTypeBorder)
		{
			[player move];
			
			nextCell.type = CellTypeTemp;
			
			[self.temp addObject:nextCell];
			
			CGPoint leftPoint = [player sidePointIsLeft:YES];
			
			CGPoint rightPoint = [player sidePointIsLeft:NO];
			
			[self fillAtLX:leftPoint.x andLY:leftPoint.y andRX:rightPoint.x andRY:rightPoint.y];
			
			[self update];
			
			return;
		}
		else if(nextCell.type == CellTypeClosed)
		{
			nextCell.type = CellTypeTemp;
			
			[self.temp addObject:nextCell];
		}
	}
	else if(curCell.type == CellTypeBorder)
	{
		if(!nextCell || (!player.forcedDirection && nextCell.type != CellTypeBorder) || (player.forcedDirection && nextCell.type != CellTypeClosed))
		{
			player.forcedDirection = NO;
			
			CGPoint leftPoint = [player sidePointIsLeft:YES];
			
			CellView * leftCell = nil;
			
			if(leftPoint.x >= 0 && leftPoint.y >= 0 && leftPoint.x < FIELD_WIDTH && leftPoint.y < FIELD_HEIGHT)
				leftCell = cells[(int)leftPoint.y][(int)leftPoint.x];
			
			if(leftCell && leftCell.type == CellTypeBorder)
			{
				switch (player.direction)
				{
					case DirectionUp:
						player.direction = DirectionLeft;
						break;
						
					case DirectionRight:
						player.direction = DirectionUp;
						break;
						
					case DirectionDown:
						player.direction = DirectionRight;
						break;
						
					case DirectionLeft:
						player.direction = DirectionDown;
						break;
				}
			}
			else
			{
				switch (player.direction)
				{
					case DirectionUp:
						player.direction = DirectionRight;
						break;
						
					case DirectionRight:
						player.direction = DirectionDown;
						break;
						
					case DirectionDown:
						player.direction = DirectionLeft;
						break;
						
					case DirectionLeft:
						player.direction = DirectionUp;
						break;
				}
			}
			
			[self update];
			
			return;
		}
		else if(nextCell.type == CellTypeClosed)
		{
			curCell.type = CellTypeTemp;
			
			[self.temp addObject:curCell];
			
			nextCell.type = CellTypeTemp;
			
			[self.temp addObject:nextCell];
		}
	}
		
	player.forcedDirection = NO;
	
	[player move];
		
	[self performSelector:@selector(update) withObject:nil afterDelay:UPDATE_DELAY];
}

- (void)handleSwipeFromRecognizer:(UISwipeGestureRecognizer*)recognizer
{
	player.forcedDirection = YES;
	
	switch (recognizer.direction)
	{
		case UISwipeGestureRecognizerDirectionUp:
			player.direction = DirectionUp;
			break;
			
		case UISwipeGestureRecognizerDirectionDown:
			player.direction = DirectionDown;
			break;
			
		case UISwipeGestureRecognizerDirectionLeft:
			player.direction = DirectionLeft;
			break;
			
		case UISwipeGestureRecognizerDirectionRight:
			player.direction = DirectionRight;
			break;
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(update) object:nil];
	
	[self update];
}

-(void)fillWaveAtX:(int)x andY:(int)y
{
	CellView * currentCell = cells[y][x];
	
	if(currentCell.type == CellTypeClosed || currentCell.type == CellTypeBorder)
		currentCell.type = CellTypeOpened;
	
	CellView * rightCell = nil;
	CellView * downCell = nil;
	CellView * leftCell = nil;
	CellView * upCell = nil;
	
	if(x + 1 < FIELD_WIDTH)
		rightCell = cells[y][x + 1];
	
	if(y -1 >= 0)
		downCell = cells[y - 1][x];
	
	if(x - 1 >= 0)
		leftCell = cells[y][x - 1];
	
	if(y + 1 < FIELD_HEIGHT)
		upCell = cells[y + 1][x];
	
	if(rightCell && (rightCell.type == CellTypeClosed || rightCell.type == CellTypeBorder))
		[self fillWaveAtX:x + 1 andY:y];
	
	if(downCell && (downCell.type == CellTypeClosed || downCell.type == CellTypeBorder))
		[self fillWaveAtX:x andY:y - 1];
	
	if(leftCell && (leftCell.type == CellTypeClosed || leftCell.type == CellTypeBorder))
		[self fillWaveAtX:x - 1 andY:y];
		
	if(upCell && (upCell.type == CellTypeClosed || upCell.type == CellTypeBorder))
		[self fillWaveAtX:x andY:y + 1];
}

-(void)checkWaveAtX:(int)x andY:(int)y isLeft:(BOOL)isLeft
{
	if(isLeft)
		leftCount++;
	else
		rightCount++;
	
	CellType currentCell = check[y][x];
	
	if(currentCell == CellTypeClosed || currentCell == CellTypeBorder)
		check[y][x] = CellTypeOpened;
	
	CellType rightCell = CellTypeUnknown;
	CellType downCell = CellTypeUnknown;
	CellType leftCell = CellTypeUnknown;
	CellType upCell = CellTypeUnknown;
	
	if(x + 1 < FIELD_WIDTH)
		rightCell = check[y][x + 1];
	
	if(y -1 >= 0)
		downCell = check[y - 1][x];
	
	if(x - 1 >= 0)
		leftCell = check[y][x - 1];
	
	if(y + 1 < FIELD_HEIGHT)
		upCell = check[y + 1][x];
	
	if(rightCell != CellTypeUnknown && (rightCell == CellTypeClosed || rightCell == CellTypeBorder))
		[self checkWaveAtX:x + 1 andY:y isLeft:isLeft];
	
	if(downCell != CellTypeUnknown && (downCell == CellTypeClosed || downCell == CellTypeBorder))
		[self checkWaveAtX:x andY:y - 1 isLeft:isLeft];
	
	if(leftCell != CellTypeUnknown && (leftCell == CellTypeClosed || leftCell == CellTypeBorder))
		[self checkWaveAtX:x - 1 andY:y isLeft:isLeft];
	
	if(upCell != CellTypeUnknown && (upCell == CellTypeClosed || upCell == CellTypeBorder))
		[self checkWaveAtX:x andY:y + 1 isLeft:isLeft];
}

-(void)fillAtLX:(int)lx andLY:(int)ly andRX:(int)rx andRY:(int)ry
{
	leftCount = 0;
	rightCount = 0;
	
	for(int y = 0; y < FIELD_HEIGHT; y++)
		for(int x = 0; x < FIELD_WIDTH; x++)
			check[y][x] = ((CellView*)cells[y][x]).type;
		
	[self checkWaveAtX:lx andY:ly isLeft:YES];
	[self checkWaveAtX:rx andY:ry isLeft:NO];
	
	if(leftCount >= rightCount)
	   [self fillWaveAtX:rx andY:ry];
	else
		[self fillWaveAtX:lx andY:ly];
	
	[self turnTempToBorder];
}

-(void)turnTempToBorder
{
	while ([self.temp lastObject])
	{
		((CellView*)[self.temp lastObject]).type = CellTypeBorder;
		
		[self.temp removeLastObject];
	}
}

@end
