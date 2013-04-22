//
//  MACDCalculator.h
//  Indicators
//
//  Created by Edward Khorkov on 25.10.11.
//  Copyright 2011 Polecat. All rights reserved.
//

#import "Indicator.h"
#import "IndicatorCalcProtocol.h"
#import "AveragingType.h"

#define DEFAULT_MACD_LENGTH 9
#define DEFAULT_FAST_LENGTH 12 
#define DEFAULT_SLOW_LENGTH 26

@interface MACDCalculator : Indicator <IndicatorCalcProtocol>

@property (nonatomic, assign, readwrite) int macdAveragingLength;
@property (nonatomic, assign, readwrite) int fastAveragingLength;
@property (nonatomic, assign, readwrite) int slowAveragingLength;

- (id)initWithMACDLength:(int)macdLength fastLength:(int)fastLength slowLength:(int)slowLength averagingType:(enum AveragingType)avType;

- (void) setMovingAverageType:(enum AveragingType)type;

@end
