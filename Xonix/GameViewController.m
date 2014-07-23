//
//  GameViewController.m
//  Xonix
//
//  Created by admin on 17.07.14.
//  Copyright (c) 2014 ch. All rights reserved.
//

#import "GameViewController.h"
#import "Cell.h"
#import "PlayerView.h"
#import "EnemyView.h"
#import <QuartzCore/QuartzCore.h>

#define FIELD_WIDTH 50

#define FIELD_HEIGHT 70

#define UPDATE_DELAY 0.03

@interface GameViewController ()
{
	IBOutlet UIImageView *imageView;
	IBOutlet UIView *gameView;
	IBOutlet UIImageView *cropView;
	IBOutlet UILabel *labelYouHave;
	IBOutlet UILabel *labelYouNeed;
	IBOutlet UILabel *labelLivesCount;
	IBOutlet UILabel *labelLevelNum;
	IBOutlet UILabel *labelScore;
	IBOutlet UIView *menuView;
	IBOutlet UIView *completeView;
	IBOutlet UIImageView *completeImageView;
	
	CGSize cellSize;
	
	CellType check[FIELD_HEIGHT][FIELD_WIDTH];
	Cell * cells[FIELD_HEIGHT][FIELD_WIDTH];
	PlayerView * player;
	
	int leftCount;
	int rightCount;
	int enemyCount;
	int livesCount;
	int scoreCount;
	int score;
	int levelNum;
	int openedCells;
	int persentComplete;
	int persentNeeded;
	
	BOOL isDead;
	
	CGMutablePathRef clipPath;
	CAShapeLayer *shape;
	CGMutablePathRef tempPath;
	CAShapeLayer *tempShape;
}

@property (nonatomic, strong) NSMutableArray * temp;
@property (nonatomic, strong) NSMutableArray * enemies;

@end

@implementation GameViewController

@synthesize temp = _temp, enemies = _enemies;

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
	
	isDead = NO;
	openedCells = 0;
	score = 0;
	livesCount = 3;
	levelNum = 1;
	persentNeeded = 75;
	persentComplete = 0;
	enemyCount = 6;
	
	CGRect rect = menuView.frame;
	rect.origin.y = [UIScreen mainScreen].bounds.size.height;
	menuView.frame = rect;
	
	[self updateLabels];
	
	CGSize size = gameView.frame.size;
	cellSize = CGSizeMake(size.width / FIELD_WIDTH, size.width / FIELD_WIDTH);
	
	imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, cellSize.height * FIELD_HEIGHT);
	cropView.frame = imageView.frame;
	gameView.frame = imageView.frame;
	
	completeImageView.image = imageView.image;
	
	self.temp = [NSMutableArray new];
	self.enemies = [NSMutableArray new];
	
	for(int y = 0; y < FIELD_HEIGHT; y++)
		for (int x = 0; x < FIELD_WIDTH; x++)
		{
			Cell *cell = [[Cell alloc] initWithPosition:CGPointMake(x * cellSize.width, y * cellSize.height)];
			
			if(y == 0 || y == FIELD_HEIGHT - 1 || x == 0 || x == FIELD_WIDTH - 1)
			{
				cell.type = CellTypeBorder;
			}
			
			cells[y][x] = cell;
			check[y][x] = cell.type;
		}
	
	player = [[PlayerView alloc] initWithFrame:CGRectMake(0, (FIELD_HEIGHT - 1) * cellSize.height, cellSize.width, cellSize.height)];
	player.position = CGPointMake(0, FIELD_HEIGHT - 1);
	player.direction = DirectionRight;
	
	[gameView addSubview:player];
	
	for (int i = 0; i < enemyCount; i++)
	{
		CGPoint pos = CGPointMake(rand() % (FIELD_WIDTH - 2) + 1, rand() % (FIELD_HEIGHT - 2) + 1);
		
		EnemyView * enemy = [[EnemyView alloc] initWithFrame:CGRectMake(pos.x * cellSize.height, pos.y * cellSize.height, cellSize.width, cellSize.height)];
		enemy.position = pos;
		enemy.type = (i < 4 ? i : 0);
		
		[self.enemies addObject:enemy];
		
		[gameView addSubview:enemy];
	}
	
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
	
	[self clipImage];
	
	[self performSelector:@selector(update) withObject:nil afterDelay:0];
}

-(void)updateLabels
{
	labelLivesCount.text = [NSString stringWithFormat:@"x %d", livesCount];
	labelLevelNum.text = [NSString stringWithFormat:@"LEVEL %d", levelNum];
	labelScore.text = [NSString stringWithFormat:@"%.8d", score];
	labelYouHave.text = [NSString stringWithFormat:@"YOU HAVE: %d%%", persentComplete];
	labelYouNeed.text = [NSString stringWithFormat:@"YOU NEED: %d%%", persentNeeded];
}

-(void)update
{
	if(isDead)
		return;
	
	CGPoint nextPoint = [player nextMove];
	
	Cell * nextCell = nil;
	
	if(nextPoint.x >= 0 && nextPoint.y >= 0 && nextPoint.x < FIELD_WIDTH && nextPoint.y < FIELD_HEIGHT)
		nextCell = cells[(int)nextPoint.y][(int)nextPoint.x];
	
	Cell * curCell = cells[(int)player.position.y][(int)player.position.x];
	
	if(curCell.type == CellTypeTemp)
	{
		if(nextCell.type == CellTypeTemp)
		{
			[self killPlayer];
			
			return;
		}
		else if(nextCell.type == CellTypeBorder)
		{
			[player move];
			
			nextCell.lastType = nextCell.type;
			
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
			nextCell.lastType = nextCell.type;
			
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
			
			Cell * leftCell = nil;
			
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
			curCell.lastType = curCell.type;
			
			curCell.type = CellTypeTemp;
			
			[self.temp addObject:curCell];
			
			nextCell.lastType = nextCell.type;
			
			nextCell.type = CellTypeTemp;
			
			[self.temp addObject:nextCell];
		}
	}
		
	player.forcedDirection = NO;
	
	[player move];
	
	[self createTemp];
	
	for (EnemyView * enemy in self.enemies)
	{
		CGPoint nextPoint = [enemy nextMove];
		
		Cell * nextCell = cells[(int)nextPoint.y][(int)nextPoint.x];
		Cell * horCell = cells[(int)enemy.position.y][(int)nextPoint.x];
		Cell * verCell = cells[(int)nextPoint.y][(int)enemy.position.x];
		
		if(nextCell.type == CellTypeBorder)
		{
			if(horCell.type == CellTypeBorder && verCell.type == CellTypeBorder)
			{
				[enemy changeDirectionIsHorizontal:YES];
				[enemy changeDirectionIsHorizontal:NO];
			}
			else if(horCell.type == CellTypeBorder)
				[enemy changeDirectionIsHorizontal:YES];
			else
				[enemy changeDirectionIsHorizontal:NO];
		}
		else if(nextCell.type == CellTypeTemp || CGPointEqualToPoint(nextPoint, player.position))
		{
			isDead = YES;
			
			[enemy killWithCompletionHandler:^{
				isDead = NO;
				[self killPlayer];
			}];
			
			return;
		}
		else
		{
			[enemy move];
		}
	}
		
	[self performSelector:@selector(update) withObject:nil afterDelay:UPDATE_DELAY];
}

-(void)killPlayer
{
	livesCount--;
	
	if(livesCount < 0)
	{
		livesCount = 0;
		
		isDead = YES;
		
		appDelegate.window.rootViewController = [GameViewController new];
		
		return;
	}
	
	[self updateLabels];
	
	[self turnTempToOrigin];
	
	for(int y = 0; y < FIELD_HEIGHT; y++)
		for (int x = 0; x < FIELD_WIDTH; x++)
		{
			CellType cellType = check[y][x];
			
			if(cellType == CellTypeBorder)
			{
				player.position = CGPointMake(x, y);
				
				player.frame = CGRectMake(player.position.x * player.frame.size.width, player.position.y * player.frame.size.height,
										  player.frame.size.width, player.frame.size.height);
			}
		}
	
	[self update];
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
	Cell * currentCell = cells[y][x];
	
	if(currentCell.type == CellTypeClosed || currentCell.type == CellTypeBorder)
	{
		currentCell.type = CellTypeOpened;
		
		openedCells++;
		scoreCount++;
		
		NSMutableArray * killedEnemies = [NSMutableArray new];
		
		for (EnemyView * enemy in self.enemies)
		{
			if(CGPointEqualToPoint(CGPointMake(x, y), CGPointMake((int)enemy.position.x, (int)enemy.position.y)))
			{
				[enemy killWithCompletionHandler:^{
					[enemy removeFromSuperview];
				}];
				
			   [killedEnemies addObject:enemy];
				
				switch (enemy.type)
				{
					case EnemyTypeFreeze:
						for (EnemyView * enemyToFreeze in self.enemies)
						{
							[enemyToFreeze freeze];
						}
						break;
						
					case EnemyTypeScore:
						scoreCount += 100;
						break;
						
					case EnemyTypeLife:
						livesCount++;
						break;
						
					case EnemyTypeRegular:
						break;
				}
			}
		}
		
		[self.enemies removeObjectsInArray:killedEnemies];
	}
	
	Cell * rightCell = nil;
	Cell * downCell = nil;
	Cell * leftCell = nil;
	Cell * upCell = nil;
	
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

-(void)createClipPathAtX:(int)x andY:(int)y
{
	CellType currentCell = check[y][x];
	
	if(currentCell == CellTypeBorder)
	{
		check[y][x] = CellTypeUnknown;
		
//		NSLog(@"%f %f", x * cellSize.width + cellSize.width / 2, y * cellSize.height + cellSize.height / 2);
		
		if(player.position.x == x && player.position.y == y)
			CGPathMoveToPoint(clipPath, NULL, x * cellSize.width + cellSize.width / 2, y * cellSize.height + cellSize.height / 2);
		else
			CGPathAddLineToPoint(clipPath, NULL, x * cellSize.width + cellSize.width / 2, y * cellSize.height + cellSize.height / 2);
	}
	
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
	
	if(rightCell != CellTypeUnknown && rightCell == CellTypeBorder)
		[self createClipPathAtX:x + 1 andY:y];
	
	if(downCell != CellTypeUnknown && downCell == CellTypeBorder)
		[self createClipPathAtX:x andY:y - 1];
	
	if(leftCell != CellTypeUnknown && leftCell == CellTypeBorder)
		[self createClipPathAtX:x - 1 andY:y];
	
	if(upCell != CellTypeUnknown && upCell == CellTypeBorder)
		[self createClipPathAtX:x andY:y + 1];
}

-(void)fillAtLX:(int)lx andLY:(int)ly andRX:(int)rx andRY:(int)ry
{
	leftCount = 0;
	rightCount = 0;
	
	[self copyCellStates];
	
	[self checkWaveAtX:lx andY:ly isLeft:YES];
	[self checkWaveAtX:rx andY:ry isLeft:NO];
	
	scoreCount = 0;
	
	if(leftCount >= rightCount)
	{
		[self fillWaveAtX:rx andY:ry];
	}
	else
	{
		[self fillWaveAtX:lx andY:ly];
	}
	
	[self turnTempToBorder];
	
	[self clipImage];
	
	persentComplete = (openedCells * 100) / (FIELD_WIDTH * FIELD_HEIGHT);
	
	if(persentComplete >= persentNeeded)
	{
		isDead = YES;
		
		[self.view addSubview:completeView];
		
		completeView.frame = imageView.frame;
		
		[UIView animateWithDuration:0.4 animations:^{
			completeView.frame = [UIScreen mainScreen].bounds;
		}];
	}
	
	if(scoreCount >= 0 && scoreCount < 100)
		score += scoreCount * 10;
	else if(scoreCount >= 100 && scoreCount < 500)
		score += scoreCount * 100;
	else if(scoreCount >= 500)
		score += scoreCount * 250;
		
	[self updateLabels];
}

-(void)createTemp
{
	if(tempPath)
		CGPathRelease(tempPath);
	
	tempPath = CGPathCreateMutable();
	
	for(int i = 0; i < self.temp.count; i++)
	{
		Cell * cell = self.temp[i];
		
		if(i == 0)
			CGPathMoveToPoint(tempPath, NULL, cell.position.x + cellSize.width / 2, cell.position.y + cellSize.height / 2);
		else
			CGPathAddLineToPoint(tempPath, NULL, cell.position.x + cellSize.width / 2, cell.position.y + cellSize.height / 2);
	}
	
	if(!tempShape)
		tempShape = [CAShapeLayer layer];
	
	tempShape.frame = gameView.bounds;
	tempShape.path = tempPath;
	tempShape.lineWidth = cellSize.width;
	tempShape.strokeColor = [UIColor whiteColor].CGColor;
	tempShape.fillColor = [UIColor clearColor].CGColor;
	
	[gameView.layer insertSublayer:tempShape above:shape];
}

-(void)clipImage
{
	[self copyCellStates];
	
	CAShapeLayer* mask = [CAShapeLayer layer];
	
	if(clipPath)
		CGPathRelease(clipPath);
	
	clipPath = CGPathCreateMutable();
	
	[self createClipPathAtX:player.position.x andY:player.position.y];
	
	CGPathCloseSubpath(clipPath);
	
	mask.path = clipPath;
	
	[cropView.layer setMask:mask];
	
	if(!shape)
		shape = [CAShapeLayer layer];
	
	shape.frame = gameView.bounds;
	shape.path = clipPath;
	shape.lineWidth = cellSize.width;
	shape.strokeColor = [UIColor whiteColor].CGColor;
	shape.fillColor = [UIColor clearColor].CGColor;
	
	[gameView.layer insertSublayer:shape atIndex:0];
}

-(void)copyCellStates
{
	for(int y = 0; y < FIELD_HEIGHT; y++)
		for(int x = 0; x < FIELD_WIDTH; x++)
			check[y][x] = cells[y][x].type;
}

-(void)turnTempToBorder
{
	while ([self.temp lastObject])
	{
		((Cell*)[self.temp lastObject]).type = CellTypeBorder;
		
		[self.temp removeLastObject];
	}
}

-(void)turnTempToOrigin
{
	while ([self.temp lastObject])
	{
		((Cell*)[self.temp lastObject]).type = ((Cell*)[self.temp lastObject]).lastType;
		
		[self.temp removeLastObject];
	}
	
	for(int y = 0; y < FIELD_HEIGHT; y++)
		for(int x = 0; x < FIELD_WIDTH; x++)
			check[y][x] = ((Cell*)cells[y][x]).type;
}

-(IBAction)buttonNextLevelPressed
{
	appDelegate.window.rootViewController = [GameViewController new];
}

@end
