//
//  Indicator.h
//  Indicators
//
//  Created by Edward Khorkov on 25.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InputDataOrder.h"

@interface Indicator : NSObject

- (NSArray *)calculateForDataArray:(NSArray *)data forValueNamed:(NSString *)valueName ordered:(enum InputDataOrder)order;
- (NSArray *)calculateForDataArray:(NSArray *)data
                 forHighValueNamed:(NSString *)highValName
                 currentValueNamed:(NSString *)currentValName
                     lowValueNamed:(NSString *)lowValName
                           ordered:(enum InputDataOrder)order;

@end
