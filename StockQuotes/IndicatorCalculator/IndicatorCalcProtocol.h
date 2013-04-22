//
//  IndicatorCalcProtocol.h
//  Indicators
//
//  Created by Edward Khorkov  on 24.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "InputDataOrder.h"

@protocol IndicatorCalcProtocol <NSObject>

- (NSArray *)calculateForDataArray:(NSArray *)data forValueNamed:(NSString *)valueName ordered:(enum InputDataOrder)order;

@end
