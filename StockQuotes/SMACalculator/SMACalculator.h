//
//  EMACalculator.h
//  Indicators
//
//  Created by Edward Khorkov on 20.10.11.
//  Copyright 2011 Polecat. All rights reserved.
// 

#import "Indicator.h"
#import "MACalcProtocol.h"
#import "IndicatorCalcProtocol.h"

#define DEFAULT_SMA_LENGTH 10

@interface SMACalculator : Indicator <IndicatorCalcProtocol, MACalcProtocol>

@property (nonatomic, assign, readwrite) int averagingIntervalLength;

- (id)initWithAveragingIntervalLength:(int)initAveragingIntervalLength;//desigated intializer

+ (NSNumber *)calculateForNumbers:(NSArray *)numbers;

- (NSArray *)calculateExtendedMAForNumbers:(NSArray *)numbers;

- (NSArray *)calculateArrayOfIndicatorsFromNumbers:(NSArray *)numbers;

@end
