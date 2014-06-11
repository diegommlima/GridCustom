//
//  GridView.m
//  CustomGridView
//
//  Created by Diego Lima on 06/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "GridView.h"

@interface GridView ()

@property (nonatomic, strong) NSArray *gridRects;
@property (nonatomic, strong) NSMutableDictionary *gridCells;
@property (nonatomic, strong) NSMutableSet *reuseableCells;

@property (nonatomic, strong) NSArray *leftViewRects;
@property (nonatomic, strong) NSMutableDictionary *leftViewCells;
@property (nonatomic, strong) NSMutableSet *leftViewReuseableCells;

@property (nonatomic, strong) NSArray *headerRects;
@property (nonatomic, strong) NSMutableDictionary *headerCells;
@property (nonatomic, strong) NSMutableSet *headerReuseableCells;

@property (nonatomic) CGFloat maximumContentWidth;
@property (nonatomic) CGFloat maximumContentHeight;
@property (nonatomic) CGRect visibleRect;

@property (nonatomic, strong) UIView *anchorLeftView;
@property (nonatomic, strong) UIView *anchorView;
@property (nonatomic, strong) UIView *anchorHeaderView;

@end


@implementation GridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.frame = frame;
        [self _performInit];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _performInit];
    }
    return self;
}

- (void)_performInit
{
    self.directionalLockEnabled = YES;
    self.opaque = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    self.bounceInSections = NO;

    self.gridCells = [NSMutableDictionary dictionary];
    self.reuseableCells = [NSMutableSet set];
    
    self.leftViewCells = [NSMutableDictionary dictionary];
    self.leftViewReuseableCells = [NSMutableSet set];
    
    self.headerCells = [NSMutableDictionary dictionary];
    self.headerReuseableCells = [NSMutableSet set];
    
    self.maximumContentHeight = CGFLOAT_MAX;
    self.maximumContentWidth = CGFLOAT_MAX;

    self.anchorLeftView = [[UIView alloc] init];
    self.anchorLeftView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.anchorLeftView];
    
    self.anchorHeaderView = [[UIView alloc] init];
    self.anchorHeaderView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.anchorHeaderView];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self loadCellsInRect:self.visibleRect];
    [self loadLeftViewsCellsInRect:self.visibleRect];
    [self loadHeaderViewsCellsInRect:self.visibleRect];

    float centerAnchorX;
    float centerAnchorY;
    float centerHeaderX;
    float centerLeftY;
    
    if (self.bounceInSections) {
        centerAnchorX = (self.contentOffset.x > 0) ? self.contentOffset.x : 0.0f;
        centerAnchorY = (self.contentOffset.y > 0) ? self.contentOffset.y : 0.0f;
        
        centerHeaderX = self.anchorHeaderView.frame.size.width/2;
        centerLeftY = self.anchorLeftView.frame.size.height/2;
    }
    else {
        centerAnchorX = self.contentOffset.x;
        centerAnchorY = self.contentOffset.y;
        
        centerHeaderX = (self.contentOffset.x > 0) ? 0.0f : self.contentOffset.x;
        centerLeftY = (self.contentOffset.y > 0) ? 0.0f : self.contentOffset.y;

        centerHeaderX += self.anchorHeaderView.frame.size.width/2;
        centerLeftY += self.anchorLeftView.frame.size.height/2;
    }
    
    centerAnchorX +=(self.anchorView.frame.size.width/2);
    centerAnchorY +=(self.anchorView.frame.size.height/2);
    centerHeaderX +=self.anchorView.frame.size.width;
    centerLeftY +=self.anchorView.frame.size.height;

    self.anchorView.center = CGPointMake(centerAnchorX, centerAnchorY);
    self.anchorLeftView.center = CGPointMake(centerAnchorX, centerLeftY);
    self.anchorHeaderView.center = CGPointMake(centerHeaderX , centerAnchorY);

    [self bringSubviewToFront:self.anchorLeftView];
    [self bringSubviewToFront:self.anchorHeaderView];
    [self bringSubviewToFront:self.anchorView];
}

- (void)reloadData {
    
    if (self.gridViewDelegate && self.superview != nil) {
        
        [self loadAnchorView];
        [self loadLeftView];
        [self loadHeaderView];

        CGFloat maxX = 0.f;
        CGFloat maxY = 0.f;

        self.gridRects = [self.gridViewDelegate rectsForCellsInGridView:self];
        [self.gridCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.reuseableCells addObjectsFromArray:self.gridCells.allValues];
        [self.gridCells removeAllObjects];

        for (GridPosition *gridPosition in self.gridRects) {
            CGRect rect = gridPosition.rectFrame;
            maxX = MAX(maxX, rect.origin.x + rect.size.width);
            maxY = MAX(maxY, rect.origin.y + rect.size.height);
        }
        
        maxX = MAX(MIN(maxX, self.maximumContentWidth), self.contentSize.width);
        maxY = MAX(MIN(maxY, self.maximumContentHeight), self.contentSize.height);
        self.contentSize = CGSizeMake(maxX, maxY);
        
        [self loadCellsInRect:self.visibleRect];
        [self loadLeftViewsCellsInRect:self.visibleRect];

        self.anchorLeftView.frame = CGRectMake(0.0f, CGRectGetMaxY(self.anchorView.frame), self.anchorView.frame.size.width, maxY-self.anchorView.frame.size.height);
        self.anchorHeaderView.frame = CGRectMake(CGRectGetMaxX(self.anchorView.frame), 0.0f, maxX-self.anchorView.frame.size.width, self.anchorView.frame.size.height);

        [self setNeedsLayout];
    }
    
}

- (void)loadAnchorView {
    [self.anchorView removeFromSuperview];
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(viewForAnchorInGridView:)]) {
        self.anchorView = [self.gridViewDelegate viewForAnchorInGridView:self];
        [self addSubview:self.anchorView];
    }
}

- (void)loadLeftView {
    
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(rectsForLeftCellsInGridView:)]) {
        self.leftViewRects = [self.gridViewDelegate rectsForLeftCellsInGridView:self];
        [self.leftViewCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.leftViewReuseableCells addObjectsFromArray:self.leftViewCells.allValues];
        [self.leftViewCells removeAllObjects];
    }
}

- (void)loadHeaderView {
    
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(rectsForHeaderCellsInGridView:)]) {
        self.headerRects = [self.gridViewDelegate rectsForHeaderCellsInGridView:self];
        [self.headerCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.headerReuseableCells addObjectsFromArray:self.leftViewCells.allValues];
        [self.headerCells removeAllObjects];
    }
}

#pragma mark - Dequeue

- (UIView *)dequeueReusableCellWithFrame:(CGRect)frame {
    UIView *reusableCell = [self.reuseableCells anyObject];
    if (reusableCell) {
        [self.reuseableCells removeObject:reusableCell];
        reusableCell.frame = frame;
    }
    return reusableCell;
}

- (UIView *)dequeueReusableLeftCellWithFrame:(CGRect)frame {
    
    UIView *reusableCell = [self.leftViewReuseableCells anyObject];
    if (reusableCell) {
        [self.leftViewReuseableCells removeObject:reusableCell];
        reusableCell.frame = frame;
    }
    return reusableCell;
}

- (UIView *)dequeueReusableHeaderCellWithFrame:(CGRect)frame {
    
    UIView *reusableCell = [self.leftViewReuseableCells anyObject];
    if (reusableCell) {
        [self.leftViewReuseableCells removeObject:reusableCell];
        reusableCell.frame = frame;
    }
    return reusableCell;
}

#pragma mark - Private Methods

- (void)loadCellsInRect:(CGRect)rectFrame {
    NSUInteger index = 0;
    NSMutableDictionary *usedCells = [NSMutableDictionary dictionary];
    
    if (self.anchorView) {
        rectFrame.origin.x = rectFrame.origin.x + self.anchorView.frame.size.width;
        rectFrame.origin.y = rectFrame.origin.y + self.anchorView.frame.size.height;
        rectFrame.size.width = rectFrame.size.width - self.anchorView.frame.size.width;
        rectFrame.size.height = rectFrame.size.height - self.anchorView.frame.size.height;
    }
    
    for (GridPosition *gridPosition in self.gridRects) {
        if (!CGRectIsEmpty(CGRectIntersection(rectFrame, gridPosition.rectFrame))) {
            UIView *gridViewCell = [self.gridCells objectForKey:gridPosition];
            if (gridViewCell == nil) {
                gridViewCell = [self.gridViewDelegate gridView:self viewForCellWithPosition:gridPosition];
                gridViewCell.userInteractionEnabled = YES;
                [gridViewCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gridHandleTap:)]];
                [self.gridCells setObject:gridViewCell forKey:gridPosition];
            }
            
            [usedCells setObject:gridViewCell forKey:gridPosition];
            [self addSubview:gridViewCell];
        }
        index ++;
    }
    
    // Move unused Cells to reusableCells
    NSMutableDictionary *unusedCells = [NSMutableDictionary dictionaryWithDictionary:self.gridCells];
    [unusedCells removeObjectsForKeys:usedCells.allKeys];
    [unusedCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.gridCells removeObjectsForKeys:unusedCells.allKeys];
    [self.reuseableCells addObjectsFromArray:unusedCells.allValues];
}

- (void)loadLeftViewsCellsInRect:(CGRect)rectFrame {

    if (!self.gridViewDelegate || ![self.gridViewDelegate respondsToSelector:@selector(gridView:leftViewForRect:index:)])
        return;
    
    NSUInteger index = 0;
    NSMutableDictionary *usedCells = [NSMutableDictionary dictionary];
    
    rectFrame.origin.x = 0;
    for (NSValue *rectValue in self.leftViewRects) {
        CGRect rectOfValue = [rectValue CGRectValue];
        if (!CGRectIsEmpty(CGRectIntersection(rectFrame, rectOfValue))) {
            UIView *leftItemViewCell = [self.leftViewCells objectForKey:rectValue];
            if (leftItemViewCell == nil) {
                leftItemViewCell = [self.gridViewDelegate gridView:self leftViewForRect:rectOfValue index:index];
                leftItemViewCell.userInteractionEnabled = YES;
                [leftItemViewCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leftHandleTap:)]];
                [self.leftViewCells setObject:leftItemViewCell forKey:rectValue];
            }
            
            [usedCells setObject:leftItemViewCell forKey:rectValue];
            [self.anchorLeftView addSubview:leftItemViewCell];
        }
        index ++;
    }
    
    // Move unused Cells to reusableCells
    NSMutableDictionary *unusedCells = [NSMutableDictionary dictionaryWithDictionary:self.leftViewCells];
    [unusedCells removeObjectsForKeys:usedCells.allKeys];
    [unusedCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.leftViewCells removeObjectsForKeys:unusedCells.allKeys];
    [self.leftViewReuseableCells addObjectsFromArray:unusedCells.allValues];
}

- (void)loadHeaderViewsCellsInRect:(CGRect)rectFrame {
    
    if (!self.gridViewDelegate || ![self.gridViewDelegate respondsToSelector:@selector(gridView:headerViewForRect:index:)])
        return;
    
    NSUInteger index = 0;
    NSMutableDictionary *usedCells = [NSMutableDictionary dictionary];
    
    rectFrame.origin.y = 0;
    for (NSValue *rectValue in self.headerRects) {
        CGRect rectOfValue = [rectValue CGRectValue];
        if (!CGRectIsEmpty(CGRectIntersection(rectFrame, rectOfValue))) {
            UIView *headerItemViewCell = [self.headerCells objectForKey:rectValue];
            if (headerItemViewCell == nil) {
                headerItemViewCell = [self.gridViewDelegate gridView:self headerViewForRect:rectOfValue index:index];
                headerItemViewCell.userInteractionEnabled = YES;
                [headerItemViewCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerHandleTap:)]];
                [self.headerCells setObject:headerItemViewCell forKey:rectValue];
            }
            
            [usedCells setObject:headerItemViewCell forKey:rectValue];
            [self.anchorHeaderView addSubview:headerItemViewCell];
        }
        index ++;
    }
    
    // Move unused Cells to reusableCells
    NSMutableDictionary *unusedCells = [NSMutableDictionary dictionaryWithDictionary:self.headerCells];
    [unusedCells removeObjectsForKeys:usedCells.allKeys];
    [unusedCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self.headerCells removeObjectsForKeys:unusedCells.allKeys];
    [self.headerReuseableCells addObjectsFromArray:unusedCells.allValues];
}

- (CGRect)visibleRect {
    CGRect visibleRect;
    
    visibleRect.origin.x = MAX(self.contentOffset.x, 0.0f);
    visibleRect.origin.y = MAX(self.contentOffset.y, 0.0f);
    visibleRect.size = self.bounds.size;
    
    float scale = 1.0 / self.zoomScale;
    visibleRect.origin.x *= scale;
    visibleRect.origin.y *= scale;
    visibleRect.size.width *= scale;
    visibleRect.size.height *= scale;
    _visibleRect = visibleRect;
    return _visibleRect;
}

#pragma mark - Tap Items
- (void)gridHandleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectCell:indexPath:)]) {
        
        NSInteger idx = INT_MAX;
        idx = [self.gridCells.allValues indexOfObject:gestureRecognizer.view];
        
        if (idx != INT_MAX) {
            GridPosition *grid = [self.gridCells.allKeys objectAtIndex:idx];
            [self.gridViewDelegate gridView:self didSelectCell:gestureRecognizer.view indexPath:grid.indexPath];
        }
        
    }
}

- (void)leftHandleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectLeftCell:index:)]) {
        
        [self.gridViewDelegate gridView:self didSelectLeftCell:gestureRecognizer.view index:[self.leftViewRects indexOfObject:[NSValue valueWithCGRect:gestureRecognizer.view.frame]]];
    }
}

- (void)headerHandleTap:(UIGestureRecognizer *)gestureRecognizer {
    if (self.gridViewDelegate && [self.gridViewDelegate respondsToSelector:@selector(gridView:didSelectHeaderCell:index:)]) {
        
        [self.gridViewDelegate gridView:self didSelectLeftCell:gestureRecognizer.view index:[self.leftViewRects indexOfObject:[NSValue valueWithCGRect:gestureRecognizer.view.frame]]];
    }
}

@end
