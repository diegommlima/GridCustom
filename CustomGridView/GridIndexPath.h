//
//  GridIndexPath.h
//  CustomGridView
//
//  Created by Diego Lima on 06/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GridIndexPath : NSObject <NSCopying>

+ (GridIndexPath *)indexPathForRow:(NSInteger)row inColumn:(NSInteger)column;

@property (nonatomic,assign) NSInteger row;
@property (nonatomic,assign) NSInteger column;

- (BOOL)isEqualToIndexPath:(GridIndexPath *)object;

@end
