//
//  GridViewController.m
//  CustomGridView
//
//  Created by Diego Lima on 06/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "GridViewController.h"
#import "NSDate+Helper.h"
#import "GridView.h"

@interface GridViewController () <GridViewDelegate>

@property (nonatomic, strong) GridView *gridView;
@property (nonatomic, strong) NSMutableArray *arrayChannels;
@property (nonatomic, strong) NSMutableArray *arrayTimes;
@property (nonatomic, strong) NSTimer *timer;

@end

static int kTimeStampSection = 60*30;
static int kDayTimeStamp = 3600*24;
static int kNumberOfDays = 11;

static int kHeightSection = 45;
static int kHeightItem = 60;
static int kWidthSection = 125;
static int kWidthfor30Minutes = 120;

@implementation GridViewController

- (void)dealloc {
    
    [self.timer invalidate];
    self.timer = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.gridView = [[GridView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.gridView.gridViewDelegate = self;
    self.gridView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.gridView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 2, 0.0f)];
    imgView.backgroundColor = [UIColor yellowColor];
    [self.gridView setFloatingView:imgView];
    
    self.arrayChannels = [NSMutableArray array];
    self.arrayTimes = [NSMutableArray array];
    
    NSTimeInterval timeStampMin = [NSDate todayWithHours:4].timeIntervalSince1970;
    NSTimeInterval timeStampMax = timeStampMin + (kNumberOfDays * kDayTimeStamp);

    NSTimeInterval temp = timeStampMin;
    
    while (timeStampMax > temp) {
        [self.arrayTimes addObject:@(temp)];
        temp +=kTimeStampSection;
    }
    
    for (int i = 0; i<20; i++) {
        
        NSTimeInterval timestamp = timeStampMin;
        NSMutableArray *arrayChannel = [NSMutableArray array];
        
        while (timestamp < timeStampMax) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            int randNum = rand() % ((kTimeStampSection*4) - (kTimeStampSection)) + kTimeStampSection;

            [dict setObject:@(timestamp) forKey:@"timeInit"];
            [dict setObject:@(randNum) forKey:@"duration"];
            [dict setObject:[NSString stringWithFormat:@"%@ - %@",[NSDate convertDateToString:[NSDate dateWithTimeIntervalSince1970:timestamp]], [NSDate convertDateToString:[NSDate dateWithTimeIntervalSince1970:timestamp + randNum]]] forKey:@"name"];
            
            [arrayChannel addObject:dict];
            timestamp += randNum;
        }
        [self.arrayChannels addObject:arrayChannel];
    }
    
    [self.gridView reloadData];
    
    [self updateNowTime];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateNowTime) userInfo:nil repeats:YES];
}

- (void)updateNowTime {
    
    NSTimeInterval timeStampMin = [NSDate todayWithHours:4].timeIntervalSince1970;
    float posX = ([NSDate date].timeIntervalSince1970-timeStampMin);
    self.gridView.floatingView.center = CGPointMake((((posX*kWidthfor30Minutes)/kTimeStampSection)+kWidthSection) + (self.gridView.floatingView.frame.size.width/2), self.gridView.floatingView.frame.size.height/2);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GridViewDelegate

- (NSArray *)rectsForCellsInGridView:(GridView *)gridView {

    NSMutableArray *returnedArray = [NSMutableArray array];
    int row = 0;
    NSTimeInterval timeStampMin = [NSDate todayWithHours:4].timeIntervalSince1970;
    for (NSArray *channel in self.arrayChannels) {
        
        int collum = 0;
        for (NSDictionary *dict in channel) {
            NSTimeInterval initial = [[dict objectForKey:@"timeInit"] doubleValue];
            NSTimeInterval duration = [[dict objectForKey:@"duration"] doubleValue];
            float posX = (initial-timeStampMin);
            CGRect frameProgram = CGRectMake(((posX*kWidthfor30Minutes)/kTimeStampSection)+kWidthSection, (row*kHeightItem)+kHeightSection, (duration*kWidthfor30Minutes)/kTimeStampSection, kHeightItem);
            GridPosition *pos = [[GridPosition alloc] init];
            pos.rectFrame = frameProgram;
            pos.indexPath = [GridIndexPath indexPathForRow:row inColumn:collum];
            [returnedArray addObject:pos];
            collum++;
        }
        row++;
    }
    
    return returnedArray;
}

- (NSArray *)rectsForLeftCellsInGridView:(GridView *)gridView {
    
    NSMutableArray *returnedArray = [NSMutableArray array];
    for (int row = 0; row < self.arrayChannels.count; row++) {
        CGRect framePostion = CGRectMake(0.0f, row*kHeightItem, kWidthSection, kHeightItem);
        [returnedArray addObject:[NSValue valueWithCGRect:framePostion]];
    }
    return returnedArray;
}

- (NSArray *)rectsForHeaderCellsInGridView:(GridView *)gridView {

    NSMutableArray *returnedArray = [NSMutableArray array];

    for (int collumn = 0; collumn < self.arrayTimes.count; collumn++) {
        CGRect framePostion = CGRectMake(collumn*kWidthfor30Minutes, 0.0f, kWidthfor30Minutes, kHeightSection);
        [returnedArray addObject:[NSValue valueWithCGRect:framePostion]];
    }
    return returnedArray;
}

- (UIView *)gridView:(GridView *)gridView viewForCellWithPosition:(GridPosition *)position {
    
    NSArray *array = [self.arrayChannels objectAtIndex:position.indexPath.row];
    NSDictionary *dict = [array objectAtIndex:position.indexPath.column];
    
    UILabel *cell = (UILabel *)[gridView dequeueReusableCellWithFrame:position.rectFrame]?:[[UILabel alloc] initWithFrame:position.rectFrame];
    cell.backgroundColor = [UIColor redColor];
    cell.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"name"]];
    cell.font = [UIFont fontWithName:@"Helvetica" size:12];
    cell.textAlignment = NSTextAlignmentCenter;
    cell.adjustsFontSizeToFitWidth = YES;
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;

    return cell;
}

- (UIView *)viewForAnchorInGridView:(GridView *)gridView {
    
    UILabel *cell = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kWidthSection, kHeightSection)];
    cell.backgroundColor = [UIColor greenColor];
    cell.text = [NSString stringWithFormat:@"ANCHOR!: %@",@":D"];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    return cell;
}

- (UIView *)gridView:(GridView *)gridView leftViewForRect:(CGRect)rect index:(NSUInteger)index {

    UILabel *cell = (UILabel *)[gridView dequeueReusableLeftCellWithFrame:rect]?:[[UILabel alloc] initWithFrame:rect];

    cell.backgroundColor = [UIColor blueColor];
    cell.text = [NSString stringWithFormat:@"Channel: %ld",(long)index];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    return cell;
}

- (UIView *)gridView:(GridView *)gridView headerViewForRect:(CGRect)rect index:(NSUInteger)index {
    
    UILabel *cell = (UILabel *)[gridView dequeueReusableHeaderCellWithFrame:rect]?:[[UILabel alloc] initWithFrame:rect];
    
    cell.backgroundColor = [UIColor lightGrayColor];
    cell.text = [NSString stringWithFormat:@"%@",[NSDate convertDateToString:[NSDate dateWithTimeIntervalSince1970:[self.arrayTimes[index] doubleValue]]]];
    cell.layer.borderWidth = 1.0f;
    cell.font = [UIFont fontWithName:@"Helvetica" size:13];
    cell.textAlignment = NSTextAlignmentCenter;
    cell.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    return cell;

}

- (void)gridView:(GridView *)gridView didSelectCell:(UIView *)cell indexPath:(GridIndexPath *)indexPath {

    NSLog(@"index:%@",indexPath.description);
}

- (void)gridView:(GridView *)gridView didSelectLeftCell:(UIView *)cell index:(NSInteger)index {
    
    NSLog(@"ROW:%d",index);
}

- (void)gridView:(GridView *)gridView didSelectHeaderCell:(UIView *)cell index:(NSInteger)index {
    
    NSLog(@"HEADER:%d",index);

}
@end
