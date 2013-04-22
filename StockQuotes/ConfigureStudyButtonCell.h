//
//  ConfigureStudyValueCell.h
//  StockQuotes
//
//  Created by Edward Khorkov on 11/1/11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureStudyCell.h"

@interface ConfigureStudyButtonCell : ConfigureStudyCell
{
    NSArray *titles;
}

@property (nonatomic, strong) NSArray *titles;

- (NSString *)currentTitle;
- (void)setTitleAtIndex:(NSUInteger)index;

@end
