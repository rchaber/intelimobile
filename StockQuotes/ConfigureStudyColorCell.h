//
//  ConfigureStudyColorCell.h
//  StockQuotes
//
//  Created by Edward Khorkov on 11/1/11.
//  Copyright (c) 2011 Polecat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureStudyCell.h"

@interface ConfigureStudyColorCell : ConfigureStudyCell

- (UIColor *)chosenColor;
- (void)setColorTo:(UIColor *)color;

@end
