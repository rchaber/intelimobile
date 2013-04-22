//
//  EMACalculator.h
//  Indicators
//
//  Created by Edward Khorkov  on 21.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "Indicator.h"
#import "MACalcProtocol.h"
#import "IndicatorCalcProtocol.h"

#define DEFAULT_EMA_LENGTH 10

@interface EMACalculator : Indicator <IndicatorCalcProtocol, MACalcProtocol>

@property (nonatomic, assign, readwrite) int averagingIntervalLength;

- (id)initWithAveragingIntervalLength:(int)initAveragingIntervalLength;//desigated intializer

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers;

- (NSArray *)calculateExtendedMAForNumbers:(NSArray *)numbers;

@end
