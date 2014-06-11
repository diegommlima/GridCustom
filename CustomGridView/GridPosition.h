//
//  GridPosition.h
//  CustomGridView
//
//  Created by Diego Lima on 09/06/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GridIndexPath.h"

@interface GridPosition : NSObject <NSCopying>

@property (nonatomic, assign) CGRect rectFrame;
@property (nonatomic, strong) GridIndexPath *indexPath;

@end
