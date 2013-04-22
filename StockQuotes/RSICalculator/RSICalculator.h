//
//  RSICalculator.h
//  Indicators
//
//  Created by Edward Khorkov on 25.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "Indicator.h"
#import "IndicatorCalcProtocol.h"

#define DEFAULT_RSI_AVERAGING_LENGTH 14

@interface RSICalculator : Indicator <IndicatorCalcProtocol>

@property (nonatomic, assign, readwrite) int averagingIntervalLength;

- (id)initWithAveragingIntervalLength:(int)length; // designated initializer

@end
