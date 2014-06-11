//
//  GridIndexPath.m
//  CustomGridView
//
//  Created by Diego Lima on 06/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "GridIndexPath.h"

@implementation GridIndexPath

@synthesize column, row;

+ (GridIndexPath *)indexPathForRow:(NSInteger)_row inColumn:(NSInteger)_column;
{
    GridIndexPath *path = [[self alloc] init];
    
    path->column = _column;
    path->row = _row;
    return path;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%ld, %ld]", (long)column, (long)row];
}

- (BOOL)isEqual:(id)object
{
    return [self isEqualToIndexPath:object];
}

- (BOOL)isEqualToIndexPath:(GridIndexPath *)object
{
    if (object == nil) return NO;
    return (object->column == self->column && object->row == self->row);
}

- (id)copyWithZone:(NSZone*)zone {
    return self;
}

@end
