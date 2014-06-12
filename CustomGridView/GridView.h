//
//  GridView.h
//  CustomGridView
//
//  Created by Diego Lima on 06/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GridPosition.h"

@class GridView;

@protocol GridViewDelegate <NSObject>

@required
- (NSArray *)rectsForCellsInGridView:(GridView *)gridView;
- (UIView *)gridView:(GridView *)gridView viewForCellWithPosition:(GridPosition *)position;

@optional
- (NSArray *)rectsForLeftCellsInGridView:(GridView *)gridView;
- (NSArray *)rectsForHeaderCellsInGridView:(GridView *)gridView;

- (UIView *)viewForAnchorInGridView:(GridView *)gridView;
- (UIView *)gridView:(GridView *)gridView leftViewForRect:(CGRect)rect index:(NSUInteger)index;
- (UIView *)gridView:(GridView *)gridView headerViewForRect:(CGRect)rect index:(NSUInteger)index;

- (void)gridView:(GridView *)gridView didSelectCell:(UIView *)cell indexPath:(GridIndexPath *)indexPath;
- (void)gridView:(GridView *)gridView didSelectLeftCell:(UIView *)cell index:(NSInteger)index;
- (void)gridView:(GridView *)gridView didSelectHeaderCell:(UIView *)cell index:(NSInteger)index;


@end

@interface GridView : UIScrollView

@property (nonatomic, strong) UIView *floatingView;

@property (nonatomic, weak) id <GridViewDelegate> gridViewDelegate;
@property (nonatomic, assign) BOOL bounceInSections;

- (void)reloadData;
- (UIView *)dequeueReusableCellWithFrame:(CGRect)frame;
- (UIView *)dequeueReusableLeftCellWithFrame:(CGRect)frame;
- (UIView *)dequeueReusableHeaderCellWithFrame:(CGRect)frame;

@end



